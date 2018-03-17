module Main where

import           Control.Concurrent (threadDelay, forkIO)
import           Control.Monad (forM_)
import           Control.Monad.Catch
import qualified Graphics.UI.Threepenny as UI
import           Graphics.UI.Threepenny.Core
import           System.Process (readProcess, callProcess)
import           Text.Read (readMaybe)

appInit :: IO ()
appInit = pure ()

main :: IO ()
main = do
  appInit
  startGUI defaultConfig setup

mainDevel = do
  appInit -- can take indeterminate amount of time
  forkIO $ do
      threadDelay 500000 -- small delay so startGUI can start listening
      refreshBrowserPage
  startGUI defaultConfig setup

setup :: Window -> UI ()
setup window = do
  return window # set UI.title "Hello World!"
  button <- UI.button # set UI.text "Click me!"
  getBody window #+ [element button]
  on UI.click button $ const $ do
    element button # set UI.text "I have been clicked!"


refreshBrowserPage :: IO ()
refreshBrowserPage = do
    maybeWindows :: Either SomeException String <- try
      (readProcess "xdotool"
        ["search", "--all", "--name", "Problem loading"] "")
    case maybeWindows of
      Left _ -> return ()
      Right idStr -> forM_ (lines idStr) $ \windowId ->
        case readMaybe windowId of
          Nothing -> return ()
          Just (n :: Integer) -> do
              putStrLn $ show n
              callProcess "xdotool" ["key", "--window", show n, "CTRL+R"]
              return ()
