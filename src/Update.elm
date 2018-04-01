module Update exposing (..)

import Models exposing (Model, Player, Game, Scene, useItem)
import Msgs exposing (Msg)
import Routing exposing (parseLocation)
import List exposing (append, tail, head)

playerNextScene : Player -> String -> Player
playerNextScene p nextSceneString =
    Player p.name nextSceneString p.health p.inventory (append p.history [nextSceneString])

findScene : Maybe (List Scene) -> String -> Maybe Scene
findScene sceneList str =
    case sceneList of
        Nothing -> Nothing
        Just li ->
            case (head li) of
                Nothing -> Nothing
                Just headItem -> if headItem.id == str then
                                     Just headItem
                                 else
                                     findScene (tail li) str
        
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.OnLocationChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )
        Msgs.NextScene game choice ->
            let
                theScene = findScene (Just game.scenes) choice.goTo
            in
                case theScene of
                    Nothing -> ( {model | game = Game game.scenes game.player "Couldn't find the scene you were looking for..." }, Cmd.none )
                    Just scene ->
                        if (scene.checker game.player) then
                            ( { model | game = Game game.scenes (playerNextScene (choice.action game.player) choice.goTo) "Scene changed" }, Cmd.none )
                        else
                            ( { model | game = Game game.scenes game.player "You can't go there." }, Cmd.none )
        Msgs.UseItem game item ->
            case (useItem game.player item.name) of
                Err e -> ( { model | game = Game game.scenes game.player e }, Cmd.none)
                Ok p -> ( { model | game = Game game.scenes p "Item applied" }, Cmd.none)
