module Routing exposing (..)

import Navigation exposing (Location)
import Models exposing (Player, Route(..))
import UrlParser exposing (..)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map GameRoute top
        , map PlayerRoute (s "player")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute
