module Game.Play exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, title, src)
import Html.Events exposing (onClick)
import Msgs exposing (Msg)
import Models exposing (Game, Player, Inventory, Item, Scene, toItems)
import List exposing (head, tail, map)
import Update exposing (findScene)

view : Game -> Html Msg
view game =
       div []
           [ nav
           , p [] [text game.status]
           , messageBox game
           , list game
           ]

messageBox : Game -> Html Msg
messageBox game =
    case (findScene (Just game.scenes) game.player.scene) of
             Nothing -> text "Scene not found"
             Just scene -> div [] [p [] [text scene.description],
                                   (if not scene.isEnd then
                                        div [] [
                                        ul [] (List.map (\c -> (li [onClick (Msgs.NextScene game c)] [text c.text]))
                                               scene.choices)
                                            , ul [ class "pickups" ] (List.map (\i -> (li [onClick (Msgs.TransferItem game i)] [text i.name])) scene.pickups) ]
                                    else
                                        p [] [text "It's the end of this scene set, there aren't any more choices."])]
               
nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Info" ] ]

list : Game -> Html Msg
list game =
    div [ class "p2" ]
        [ table [] [
                tr []
                    [ th [] [ text "Name" ]
                    , th [] [ text "History" ]
                    , th [] [ text "Health" ]
                    , th [] [ text "Inventory" ]
                    ]
               
              ,  tr [] 
                      [ td [] [ text game.player.name ] 
                      , td [] [ (ul [] (List.map (\s -> (li [] [ text s ])) game.player.history)) ] 
                      , td [] [ text (toString game.player.health) ]
                      , td [] [ table [] [
                                            tr []
                                                [ th [] [ text "Name" ]
                                                  , th [] [ text "Description" ]
                                                  , th [] [ text "Options" ] ]
                                                , tbody [] (List.map
                                                     (\i -> (tr []
                                                                 [ td [] [ text i.name ]
                                                            , td [] [ text i.description ]
                                                            , td [] [ a [onClick (Msgs.UseItem game i)] [text "Use"] ] ])) (toItems game.player.inventory)) ]]
                      ]
              ] ]
