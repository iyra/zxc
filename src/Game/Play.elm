module Game.Play exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, title)
import Msgs exposing (Msg)
import Models exposing (Game, Player, Inventory, Item, toItems)

view : Game -> Player -> Html Msg
view game player =
       div []
           [ nav
           , messageBox game
           ]

messageBox : Game -> Html Msg
messageBox game =
    div []
        [ text "hi" ]
               
nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Info" ] ]
