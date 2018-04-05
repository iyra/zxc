module Models exposing (..)
import List exposing (head, map, filter, indexedMap, tail, isEmpty)
import Tuple exposing (first, second)
import Dict exposing (fromList)
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
    , pickups : List Item
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
    , status : String
    }
type Inventory = Inventory (List Item)

sceneSets = Dict.fromList [
 ("zxc", [Scene "one" "Beginning" "Welcome to the game."
          [Choice "towub" "Go to the next thing" (\p -> modHealth p 10) "two"]
          False (\p -> p.health > 50) [],
      
          Scene "two" "Next thing" "wub"
          []
          False (\p -> p.health > 80) []])]

toItems : Inventory -> List Item
toItems x = case x of
                Inventory l -> l
                               
removeFromList i xs =
  (List.take i xs) ++ (List.drop (i+1) xs)

findItem : Maybe (List Item) -> String -> Int -> Maybe (Int, Item)
findItem inv str i =
    case inv of
        Nothing -> Nothing
        Just li ->
            case (head li) of
                Nothing -> Nothing
                Just headItem -> if headItem.name == str then
                                     Just (i, headItem)
                                 else
                                     findItem (tail li) str (i+1)

findScene : Maybe (List Scene) -> String -> Int -> Maybe (Int, Scene)
findScene scs str i =
    case scs of
        Nothing -> Nothing
        Just li ->
            case (head li) of
                Nothing -> Nothing
                Just headItem -> if headItem.id == str then
                                     Just (i, headItem)
                                 else
                                     findScene (tail li) str (i+1)

transferItem : Game -> String -> Result String Game
transferItem game itemString =
    case (findScene (Just game.scenes) game.player.scene 0) of
        Nothing -> Err "That scene doesn't exist"
        Just sc -> let
            sceneIndex = first sc
            scene = second sc
       in
           case (findItem (Just scene.pickups) itemString 0) of
               Nothing -> Err "That item isn't in the scene"
               Just rt -> let
                   itemIndex = first rt
                   item = second rt
                   newScenes = { scene | pickups = (removeFromList itemIndex scene.pickups) } :: (removeFromList sceneIndex game.scenes)
                   p = game.player
              in
                  Ok (Game newScenes { p | inventory = (Inventory (item :: (toItems p.inventory)))} game.status)
                  --Ok { game | player = { p | inventory = (Inventory (item :: (toItems p.inventory)))},
                  --            scenes = newScenes }
                                      
useItem : Player -> String -> Result String Player
useItem p str =
    case (findItem (Just (toItems p.inventory)) str 0) of
               Nothing -> Err "That isn't in the backpack"
               Just rt -> let
                   itemIndex = first rt
                   item = second rt
                   playerAppliedItem = item.action p
              in
                  Ok (Player playerAppliedItem.name
                          playerAppliedItem.scene
                          playerAppliedItem.health
                          (Inventory (removeFromList itemIndex (toItems playerAppliedItem.inventory)))
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
    | WelcomeRoute
    | GameRoute
    | NotFoundRoute

modHealth : Player -> Int -> Player
modHealth p by =
    Player p.name p.scene (p.health + by) p.inventory p.history

modName : Player -> String -> Player
modName p newname =
    Player newname p.scene p.health p.inventory p.history

initialModel : Route -> Model
initialModel route =
    let
        player = { name = "Iyra"
               , scene = "one"
               , health = 15
               , inventory = Inventory [Item "bp"
                                            (\p -> (Player p.name p.scene (p.health+10) p.inventory p.history))
                                            "Base potion; add 10 to your health."
                                       ]
               , history = ["one"]
                 }
    in
        {
            player = player
        , game = { scenes = [Scene "one" "Beginning" "Welcome to the game."
                                 [Choice "towub" "Go to the next thing" (\p -> modHealth p 10) "two"]
                                 False (\p -> p.health > 50) [Item "bp"
                                            (\p -> (Player p.name p.scene (p.health+10) p.inventory p.history))
                                            "Base potion; add 10 to your health."
                                       ],
                            Scene "two" "Next thing" "wub"
                                []
                                False (\p -> p.health > 80) []]
                 , player = player
                 , status = ""}
        , route = route
        }
