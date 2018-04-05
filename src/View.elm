module View exposing (..)

import Msgs exposing (Msg)
import Models exposing (Model)
import Player.Info
import Game.Play
import Html exposing (..)
import Html.Attributes exposing (class, title, type_, placeholder, value, href)
import Html.Events exposing (onClick, onInput, on)
import Models exposing (Game, Player, Inventory, Item, Scene, toItems, sceneSets)
import List exposing (head, tail, map)
import Update exposing (findScene)
import Dict exposing (keys)
import Routing exposing (playPath)

startView : Game -> Html Msg
startView game =
       div []
           [ nav
           , p [] [text game.status]
           , div []
               [ input [ type_ "text", placeholder "Name", onInput (Msgs.ChangeName game)] []
               , select [ onInput (Msgs.ChangeSceneSet game) ]
                   (List.map (\ss -> (option [ value (toString ss) ] [ text ((toString ss)++" ("++(case Dict.get ss sceneSets of
                                                                                                         Nothing -> "?)"
                                                                                                         Just n -> (toString (List.length n))++")")) ])) (Dict.keys sceneSets))
               , a [ href playPath ] [text "Go!"] ]
           ]

nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Info" ] ]

view : Model -> Html Msg
view model =
    div []
        [ page model ]

page : Model -> Html Msg
page model =
    case model.route of
        Models.GameRoute ->
            Game.Play.view model.game
        Models.PlayerRoute ->
            Player.Info.view model.player
        Models.WelcomeRoute ->
            startView model.game
        Models.NotFoundRoute ->
            notFoundView

notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
