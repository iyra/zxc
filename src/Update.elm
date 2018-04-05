module Update exposing (..)

import Models exposing (Model, Player, Game, Scene, useItem, transferItem, modName, sceneSets, new)
import Msgs exposing (Msg)
import Routing exposing (parseLocation)
import List exposing (append, tail, head)
import Dict exposing (get)

playerNextScene : Player -> String -> Player
playerNextScene p nextSceneString =
    {p | scene = nextSceneString, history = (append p.history [nextSceneString])}

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
                    Nothing -> ( {model | game = {game | status = "Couldn't find the scene you were looking for. Contact the owner about this." } }, Cmd.none )
                    Just scene ->
                        if (scene.checker game.player) then
                            ( { model | game = {game | player = (playerNextScene (choice.action game.player) choice.goTo),
                                                       status = "Scene changed" } }, Cmd.none )
                        else
                            ( { model | game = {game | status = "You can't go there."} }, Cmd.none )
        Msgs.UseItem game item ->
            case (useItem game.player item.name) of
                Err e -> ( { model | game = Game game.scenes game.player e }, Cmd.none)
                Ok p -> ( { model | game = {game | player = p, status = "Item used"} }, Cmd.none)
        Msgs.TransferItem game item ->
            case (transferItem game item.name) of
                Err e -> ( { model | game = Game game.scenes game.player e }, Cmd.none)
                Ok p -> ( { model | game = p }, Cmd.none)
        Msgs.ChangeSceneSet game str ->
            case (Dict.get str sceneSets) of
                -- if the scene set is being changed, it makes sense to reset the player too
                -- but with the same name
                Nothing -> ( {model | game = {game | status = "That scene doesn't exist" }}, Cmd.none )
                Just value -> ({model | game = {game |
                                                scenes = value,
                                                player = { new | name = game.player.name },
                                                status = "Scene loaded."}}, Cmd.none)
        Msgs.ChangeName game str ->
            ({model | game = {game | player = (modName game.player str), status = "Name set."}}, Cmd.none)
