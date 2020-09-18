//
//  AllyTeam.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation



struct IncorrectCount: LocalizedError, CustomStringConvertible {
    let key: String

    var description: String {
        return "Incorrect number of values corresponding to key \"\(key)\""
    }
}

struct MissingScriptSection: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section

    var description: String {
        return "Missing script section \"\(section.description)\""
    }
}

struct MissingScriptArgument: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section
    let key: String

    var description: String {
        return "Missing value for script argument \"\(key)\" in section \"\(section.description)\""
    }
}
struct InvalidValueForScriptArgument<T>: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section
    let key: String
    let value: T

    var description: String {
        return "Invalid value \"\(value)\" for script argument \"\(key)\" in section \"\(section.description)\""
    }
}

struct IncorrectValueTypeScriptArgument<T>: LocalizedError, CustomStringConvertible {
    let section: ScriptSections.Section
    let key: String
    let expectedType: T.Type

    var description: String {
        return "Invalid value type for script argument \"\(key)\" in section \"\(section.description)\". Expected type \"\(expectedType)\""
    }
}


/// Information about the teams that make up an AllyTeam.
public struct AllyTeam: Equatable {
    /// An integer that is garuanteed to uniquely identify this allyteam in the start script.
    public let scriptID: Int
    /// The teams that make up this AllyTeam.
    ///
    /// Team number is determined by position in the array. (I.e. Team 0 is position 0, etc.)
    public let teams: [Team]

    public init(scriptID: Int, teams: [Team]) {
        self.teams = teams
        self.scriptID = scriptID
    }
}


struct ScriptSections {
    let value: [String : [String : String]]

    func numberOfSections(withPrefix prefix: String) -> Int {
        return value.filter({ $0.key.hasPrefix(prefix) }).count
    }

    func game(key: String) throws -> String {
        return try keyedValue(for: key, from: .game)
    }

    func sectionValues(_ section: Section) throws -> [String : String] {
        guard let values = value[section.description] else {
            throw MissingScriptSection(section: section)
        }
        return values
    }

    func keyedValue(for key: String, from section: Section) throws -> String {
        guard let keyedValue = try sectionValues(section)[key] else {
            throw MissingScriptArgument(section: section, key: key)
        }
        return keyedValue
    }

    func keyedInteger(for key: String, from section: Section) throws -> Int {
        guard let keyedInteger = try Int(keyedValue(for: key, from: section)) else {
            throw IncorrectValueTypeScriptArgument(section: section, key: key, expectedType: Int.self)
        }
        return keyedInteger
    }

    func keyedFloat(for key: String, from section: Section) throws -> Float {
        guard let keyedFloat = try Float(keyedValue(for: key, from: section)) else {
            throw IncorrectValueTypeScriptArgument(section: section, key: key, expectedType: Float.self)
        }
        return keyedFloat
    }

    enum Section {
        case game
        case modOptions
        case mapOptions
        case player(number: Int)
        case ai(number: Int)
        case team(number: Int)
        case allyteam(number: Int)
        case restrictions

        var description: String {
            switch self {
            case .game:
                return "game"
            case .modOptions:
                return "modoptions"
            case .mapOptions:
                return "mapoptions"
            case .player(let number):
                return "player\(number)"
            case .ai(let number):
                return "ai\(number)"
            case .team(let number):
                return "team\(number)"
            case .allyteam(let number):
                return "allyteam\(number)"
            case .restrictions:
                return "restrict"
            }
        }
    }
}
