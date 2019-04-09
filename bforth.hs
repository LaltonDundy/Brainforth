import System.Environment
import System.IO         
import Desugar           (evaluate)
import FF                (execute)
import Foreign.C.String  (newCString)
import Control.Monad     (unless)

iterate' :: [ String ] -> String -> IO String
iterate' []     prev          = return prev
iterate' ("-norun" : xs) prev = iterate' xs prev
iterate' (x:xs) prev          = readFile x >>= 
                                \s -> iterate' xs (prev ++ s)

norun  = flag "-norun"
flag f args = (/=) [] (filter ( f == )  args)

main = do
    args      <- getArgs
    wholeProg <- iterate' args [] 
    writeFile "output" ( evaluate wholeProg )
    unless (norun args) $
         newCString "output" >>= execute
