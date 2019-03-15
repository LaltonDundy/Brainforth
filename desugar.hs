{-#LANGUAGE GADTs #-}

module Desugar where

data Tokes = ID String
    | MoveRight | Inc        | Dec      | Output
    | GetByte   | StartWhile | EndWhile | MoveLeft

instance Show Tokes where
    show toke = case toke of
        ID str     -> str
        MoveRight  -> ">"
        MoveLeft   -> "<"
        GetByte    -> ","
        Inc        -> "+"
        Dec        -> "-"
        StartWhile -> "["
        EndWhile   -> "]"
        Output     -> "."

isNative :: Tokes -> Bool
isNative (ID _) = False
isNative _      = True

getBasic  :: (Dictionary d) => d -> [ Tokes ] -> [ Tokes ]
getBasic dict tokes
    | foldl (&&) True $ map isNative tokes = tokes
    | otherwise  = concat $ 
                   map ( \x -> 
                            ( case x of
                                ID str ->  recursiveSearch str 
                                rest   -> [ rest ] )
                            ) tokes

    where recursiveSearch str = 
            case lookup_ dict str  of 
                Just ( defin , newDict ) -> getBasic newDict defin
                Nothing                  -> error $ "String not found: " <> str

data Table = Table [ ( String , [Tokes ] ) ]
    deriving (Show)

class (Show a) => Dictionary a where
   emptyD  :: a
   newWord :: a -> String -> [ Tokes ] -> a
   lookup_ :: a -> String -> Maybe ([ Tokes] , a)
   append  :: a -> a -> a

instance Dictionary Table where
    emptyD  = Table []
    newWord (Table t) str tokes = Table $ (str , tokes) : t
    lookup_  ( Table ((name , def) : t)) str
        | str == name = Just (def , Table t)
        | otherwise =  lookup_ ( Table t) str
    lookup_ (Table []) str = Nothing
    append ( Table a ) (Table b ) = Table (a ++ b)

type TokeStack = ( Maybe String , [ Tokes ] )

addDef :: (Dictionary d) => d -> TokeStack -> d
addDef dict (Just name, stack) = newWord dict name (reverse stack)

data Runnable  d where 
    RUN :: (Dictionary d) => [ (d , [Tokes ]) ] -> Runnable d

startRun :: Runnable Table
startRun = RUN $ ( emptyD , [] ) : []

introduce :: TokeStack -> Runnable d -> Runnable d
introduce stack ( RUN (( dict , prog ) : xs)) = RUN $ (( addDef dict stack ) , []) : (dict , prog) : xs

parse  ::  (Dictionary d) => 
            Runnable d  ->
            [String]    -> 
            TokeStack   ->
            Runnable d

parse past prog ( Just name , lst ) = 
            case prog of
                 ";" : rest -> 
                    let new = introduce (Just name , lst ) past in
                    parse  new rest (Nothing , [])
                 ("<" : xs)  -> parse past xs (Just name , (MoveLeft : lst) )
                 (">" : xs)  -> parse past xs (Just name , (MoveRight : lst) )
                 ("," : xs)  -> parse past xs (Just name , (GetByte : lst) )
                 ("." : xs)  -> parse past xs (Just name , (Output : lst) )
                 ("+" : xs)  -> parse past xs (Just name , (Inc : lst) )
                 ("-" : xs)  -> parse past xs (Just name , (Dec: lst) )
                 ("[" : xs)  -> parse past xs (Just name , (StartWhile: lst) )
                 ("]" : xs)  -> parse past xs (Just name , (EndWhile: lst) )
                 (x   : xs)  -> parse past xs (Just name , ((ID x) : lst) )
                 []          -> error "non finished word definition"

parse (RUN ( (x , y) : [])) [] (Nothing , lst) = RUN $ ( emptyD , (reverse lst) ) : []
parse past prog (Nothing , lst) =
            case prog of
                 [] -> past
                 (":" : name : rest) -> parse past rest (Just name, [] )
                 ("<" : xs)  -> parse past xs (Nothing , (MoveLeft : lst) )
                 (">" : xs)  -> parse past xs (Nothing , (MoveRight : lst) )
                 ("," : xs)  -> parse past xs (Nothing , (GetByte : lst) )
                 ("." : xs)  -> parse past xs (Nothing , (Output : lst) )
                 ("+" : xs)  -> parse past xs (Nothing , (Inc : lst) )
                 ("-" : xs)  -> parse past xs (Nothing , (Dec: lst) )
                 ("[" : xs)  -> parse past xs (Nothing , (StartWhile: lst) )
                 ("]" : xs)  -> parse past xs (Nothing , (EndWhile: lst) )
                 (x:xs)      -> (
                        case past of
                            RUN (( d , rcrd ) : tl) -> parse (RUN $ ( (d ,((ID x )): rcrd)) : tl) xs (Nothing , lst)
                            _ -> error "This is not suppose to happen"
                            )

toTokes :: (Dictionary d) => Runnable d -> [Tokes] -> [ Tokes ]
toTokes (RUN ( (dict , [] )  : rest )) tokes = toTokes (RUN rest) tokes
toTokes (RUN ((dict , prog)  : rest )) tokes = toTokes (RUN rest)  (  (getBasic dict prog ) ++ tokes)
toTokes (RUN [] )                      tokes = tokes

write   :: [ Tokes ] -> String
write   = concat . ( map show )

decomment' :: String -> Bool -> String
decomment' "("         _    = error "unended comment"
decomment' ""         True  = error "unended comment"
decomment' (')' : xs) True  = decomment' xs False
decomment' ('(' : xs) False = decomment' xs True
decomment' (x:xs)     True  = decomment' xs True
decomment' (x:xs)     False = x : (decomment' xs False)
decomment' []          _    = []

decomment = \str -> decomment' str False

evaluate :: String -> String
evaluate str = write $  toTokes ( parse startRun (words . decomment $ str) (Nothing , []) ) []
