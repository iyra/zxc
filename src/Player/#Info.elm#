module Player.Info exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, title)
import Msgs exposing (Msg)
import Models exposing (Player, Inventory, Item, toItems)

view : Player -> Html Msg
view player =
    div []
        [ nav
        , list player
        ]


nav : Html Msg
nav =
    div [ class "clearfix mb2 white bg-black" ]
        [ div [ class "left p2" ] [ text "Info" ] ]

                           
list : Player -> Html Msg
list player =
    div [ class "p2" ]
        [ table [] [
                tr []
                    [ th [] [ text "Name" ]
                    , th [] [ text "Current scene" ]
                    , th [] [ text "Health" ]
                    , th [] [ text "Inventory" ]
                    ]
               
              ,  tr [] 
                      [ td [] [ text player.name ] 
                      , td [] [ text player.scene ] 
                      , td [] [ text (toString player.health) ]
                      , td [] [ ul [] (List.map (\i -> (li [] [span [title i.description] [text i.name]])) (toItems player.inventory)) ]
                      ]
                
              ]
        ]
