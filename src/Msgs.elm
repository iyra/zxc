module Msgs exposing (..)

import Models exposing (Player, Game, Choice, Item)
import Navigation exposing (Location)

type Msg = UseItem Game Item | NextScene Game Choice | OnLocationChange Location
