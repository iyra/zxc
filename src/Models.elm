module Models exposing (..)
import List exposing (head, map, filter, indexedMap)
import Tuple exposing (first)
{-| Take a predicate and a list, return the index of the first element that satisfies the predicate. Otherwise, return `Nothing`. Indexing starts from 0.
    findIndex isEven [1,2,3] == Just 1
    findIndex isEven [1,3,5] == Nothing
    findIndex isEven [1,2,4] == Just 1
-}
findIndex : (a -> Bool) -> List a -> Maybe Int
findIndex p = head << findIndices p

{-| Take a predicate and a list, return indices of all elements satisfying the predicate. Otherwise, return empty list. Indexing starts from 0.
    findIndices isEven [1,2,3] == [1]
    findIndices isEven [1,3,5] == []
    findIndices isEven [1,2,4] == [1,2]
-}
findIndices : (a -> Bool) -> List a -> List Int
findIndices p = map first << filter (\(i,x) -> p x) << indexedMap (,)
                
{-| Find the first element that satisfies a predicate and return
Just that element. If none match, return Nothing.
    find (\num -> num > 5) [2, 4, 6, 8] == Just 6
-}
find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first::rest ->
            if predicate first then
                Just first
            else
                find predicate rest

{-| Return the index of the first occurrence of the element. Otherwise, return `Nothing`. Indexing starts from 0.
    elemIndex 1 [1,2,3] == Just 0
    elemIndex 4 [1,2,3] == Nothing
    elemIndex 1 [1,2,1] == Just 0
-}
elemIndex : a -> List a -> Maybe Int
elemIndex x = findIndex ((==)x)

              
type alias Model =
    { player : Player
    , game : Game
    , route : Route
    }


type alias Choice =
    { id : String
    , text : String
    , action : Player -> Player
    , goTo : String
    }

type alias Scene =
    { id : String
    , name : String
    , description : String
    , choices : List Choice
    , isEnd : Bool
    , checker : Player -> Bool
    }

type alias Item =
    { name : String
    , action : Player -> Player
    , description : String
    }

type alias Player =
    { name : String
    , scene : String
    , health : Int
    , inventory : Inventory
    , history : List String
    }

type alias Game =
    { scenes : List Scene
    , player : Player
    }
type Inventory = Inventory (List Item)

toItems : Inventory -> List Item
toItems x = case x of
                Inventory l -> l
                               
removeFromList i xs =
  (List.take i xs) ++ (List.drop (i+1) xs)

useItem : Player -> String -> Result String Player
useItem p i =
    case find (\it -> it.name == i) (toItems p.inventory) of
        Nothing -> Err "That isn't in the backpack"
        Just itemToUse -> let
            playerAppliedItem = itemToUse.action p
       in
           case elemIndex itemToUse (toItems p.inventory) of
               Nothing -> Err "That isn't in the backpack"
               Just u -> Ok (Player playerAppliedItem.name
                                 playerAppliedItem.scene
                                 playerAppliedItem.health
                                 (Inventory (removeFromList u (toItems playerAppliedItem.inventory)))
                                 playerAppliedItem.history)
            
new : Player
new =
    { name = "Unnamed"
    , scene = "one"
    , health = 83
    , inventory = Inventory []
    , history = ["one"]
    }

type Route
    = PlayerRoute
    | GameRoute
    | NotFoundRoute


initialModel : Route -> Model
initialModel route =
    let
        player = { name = "Iyra"
               , scene = "one"
               , health = 83 
               , inventory = Inventory [Item "bp"
                                            (\p -> (Player p.name p.scene (p.health+10) p.inventory p.history))
                                            "Base potion; add 10 to your health."
                                       ]
               , history = ["one"]
                 }
    in
        {
            player = player
        , game = { scenes = []
                 , player = player }
        , route = route
        }