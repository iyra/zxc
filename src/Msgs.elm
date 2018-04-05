module Msgs exposing (..)

import Models exposing (Player, Game, Choice, Item)
import Navigation exposing (Location)

type Msg = ChangeName Game String | ChangeSceneSet Game String | UseItem Game Item | NextScene Game Choice | OnLocationChange Location | TransferItem Game Item
