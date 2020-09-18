//
//  Team.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Describes a team of players and/or AIs that will control a single set of units/resources.
public struct Team: Equatable {
    /// A unique identifier for the team.
    public let scriptID: Int
    #warning("It is unclear what effect this has, if any.")
    /// The "leader" of the team.
    public let leader: Int
    /// The human players on the team.
    public let players: [Player]
    /// The AI players on the team.
    ///
    /// Note that due to the design of AIs, AIs will likely only ever be on their own team.
    public let ais: [AI]

    /// The color assigned to the team.
    public let color: UInt32
    /// The faction assigned to the team.
    public let side: String?

    /// ??? Not sure what a handicap is.
    public let handicap: Int

    public let advantage: Float?

    public let incomeMultiplier: Float?

    /// The LuaAI controlling the team.
    public let luaAI: String?

    public init(scriptID: Int, leader: Int, players: [Player], ais: [AI], color: UInt32, side: String?, handicap: Int, advantage: Float?, incomeMultiplier: Float?, luaAI: String?) {
        self.scriptID = scriptID
        self.leader = leader
        self.players = players
        self.ais = ais
        self.color = color
        self.side = side
        self.handicap = handicap
        self.advantage = advantage
        self.incomeMultiplier = incomeMultiplier
        self.luaAI = luaAI
    }

    public static func == (lhs: Team, rhs: Team) -> Bool {
        return lhs.scriptID == rhs.scriptID &&
            lhs.leader == rhs.leader &&
            lhs.players == rhs.players &&
            lhs.ais == rhs.ais &&
            lhs.side == rhs.side &&
            lhs.handicap == rhs.handicap &&
            lhs.advantage == rhs.advantage &&
            lhs.incomeMultiplier == rhs.incomeMultiplier &&
            lhs.luaAI == rhs.luaAI
    }
}
