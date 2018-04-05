module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Player, Route(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map WelcomeRoute top
        , map GameRoute (s "play")
        , map PlayerRoute (s "player")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute

playPath : String
playPath = "#play"
