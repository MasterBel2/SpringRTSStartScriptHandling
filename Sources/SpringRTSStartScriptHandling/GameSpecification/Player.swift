//
//  Player.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation
import CountryCode

/// Describes a player that will control units of a team.
public struct Player: Equatable {
    /// An integer that is garuanteed to uniquely identify the player in the start script.
    public let scriptID: Int
    /// The unique lobby ID of the player.
    public let userID: Int?
    /// The username of the player.
    public let username: String
    /// The password the user will send on a connect attempt.
    public let scriptPassword: String?

    /// The trueskill value of the player, if they have one.
    public let skill: String?
    /// The lobby rank of the player, if applicable.
    public let rank: Int?
    /// The country code associated with the player's location.
    public let countryCode: CountryCode?

    public let isFromDemo: Bool

    public init(scriptID: Int, userID: Int?, username: String, scriptPassword: String, skill: String?, rank: Int?, countryCode: CountryCode?, isFromDemo: Bool) {
        self.scriptID = scriptID
        self.userID = userID
        self.username = username
        self.scriptPassword = scriptPassword
        self.skill = skill
        self.rank = rank
        self.countryCode = countryCode
        self.isFromDemo = isFromDemo
    }

    init(scriptID: Int, sections: ScriptSections, isFromDemo: Bool) throws {
        self.scriptID = scriptID
        userID = try? sections.keyedInteger(for: "accountid", from: .player(number: scriptID))
        username = try sections.keyedValue(for: "name", from: .player(number: scriptID))
        scriptPassword = try? sections.keyedValue(for: "password", from: .player(number: scriptID))
        skill = try? sections.keyedValue(for: "skill", from: .player(number: scriptID))
        rank = try? sections.keyedInteger(for: "rank", from: .player(number: scriptID))
        countryCode = try? CountryCode(rawValue: sections.keyedValue(for: "countrycode", from: .player(number: scriptID)).uppercased())
        self.isFromDemo = isFromDemo
    }
}
