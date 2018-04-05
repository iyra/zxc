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
             Just scene -> div [] [div [class "scene"] [span [] [text scene.name], p [] [text scene.description]],
                                   (if not scene.isEnd then
                                        div [] [
                                             div [class "choices"] [
                                                  span [] [text "Choices"],
                                        ul [] (List.map (\c -> (li [onClick (Msgs.NextScene game c)] [text c.text]))
                                               scene.choices)]
                                            , div [ class "pickups" ] [span [] [ text "Pickups" ], ul [] (List.map (\i -> (li [onClick (Msgs.TransferItem game i)] [text i.name])) scene.pickups)] ]
                                    else
                                        p [] [text "It's the end of this scene set, there aren't any more choices."])]
               
nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Info" ] ]

list : Game -> Html Msg
list game =
    div [ class "player" ]
        [ span [] [text "Player"], 
         ul [] [
               li [] [ label [] [text "Name" ], text game.player.name ] 
              , li [] [ label [] [text "History"], (ul [] (List.map (\s -> (li [] [ text s ])) game.player.history)) ] 
              , li [] [ label [] [text "Health"], span [class (if game.player.health < 30 then
                                                                   "health low-health"
                                                              else if game.player.health < 60 then 
                                                                       "health medium-health"
                                                              else if game.player.health < 80 then
                                                                       "health good-health"
                                                              else
                                                                  "health excellent-health")] [text (toString game.player.health)] ]
              , li [] [ label [] [text "Inventory"], if not (List.isEmpty (toItems game.player.inventory)) then
                            ul []
                                            (List.map
                                                     (\i -> ( div [] [label [] [text "Item" ], ul [] [
                                                                 li [] [ text i.name ]
                                                            , li [] [ text i.description ]
                                                            , div [] [ label [] [text "Actions"], ul [] [a [onClick (Msgs.UseItem game i)] [text "Use"] ] ]]])) (toItems game.player.inventory))
                              else
                                  (text "...empty...")]
                      ]
              ]
