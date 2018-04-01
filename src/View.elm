module View exposing (..)

import Html exposing (Html, div, text)
import Msgs exposing (Msg)
import Models exposing (Model)
import Player.Info
import Game.Play

view : Model -> Html Msg
view model =
    div []
        [ page model ]

page : Model -> Html Msg
page model =
    case model.route of
        Models.GameRoute ->
            Game.Play.view model.game model.player
        Models.PlayerRoute ->
            Player.Info.view model.player

        Models.NotFoundRoute ->
            notFoundView

notFoundView : Html msg
notFoundView =
    div []
        [ text "Not found"
        ]
