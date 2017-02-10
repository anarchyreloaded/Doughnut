module Main exposing (main)

import Html as App
import Model exposing (Model, Msg)
import Config exposing (Config)
import Update
import Window.Main

main : Program Config Model Msg
main =
  App.programWithFlags
    { init = Update.init
    , view = Window.Main.view
    , update = Update.update
    , subscriptions = Update.subscriptions
    }