//
//  StartConfig.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Describes how the players should be distributed for a game.
public enum StartConfig: Equatable {
    public static func == (lhs: StartConfig, rhs: StartConfig) -> Bool {
        switch lhs {
        case .chooseInGame(let startBoxesLHS):
            switch rhs {
            case .chooseInGame(let startBoxesRHS):
                return startBoxesLHS == startBoxesRHS
            default:
                return false
            }
        case .chooseBeforeGame(let startPositionsLHS):
            switch rhs {
            case .chooseBeforeGame(let startPositionsRHS):
                return startPositionsLHS == startPositionsRHS
            default:
                return false
            }
        case .fixed:
            switch rhs {
            case .fixed: return true
            default: return false
            }
        case .random:
            switch rhs {
            case .random: return true
            default: return false
            }
        }
    }

    /// Indicates that player locations have been chosen before the game.
    case chooseBeforeGame(startPositions: [Int : Coordinate])
    /// Indicates that the players should be distributed according to the map's set locations, in the order the players are given to the
    /// map.
    case fixed
    /// Indicates that the players should be allowed to select their start location in-game, within any specified start boxes.
    case chooseInGame(startBoxes: [Int : StartBox])
    /// Indicates that the players should be randomly distributed according to the map's set locations.
    case random

    public struct Coordinate: Equatable {
        public let x: Int
        public let z: Int

        public init(x: Int, z: Int) {
            self.x = x
            self.z = z
        }
    }
}
