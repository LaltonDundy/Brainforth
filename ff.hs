{-# LANGUAGE ForeignFunctionInterface #-}
module FF where

import Foreign.C.String
import Data.Text

foreign import ccall "execute" execute :: CString -> IO ()
