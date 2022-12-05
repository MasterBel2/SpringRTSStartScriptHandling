//
//  StartScriptDecoder.swift
//  ReplayParser
//
//  Created by MasterBel2 on 20/6/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation
import CountryCode

public final class GameSpecificationDecoder {

    public init() {}

    public enum GameScriptError {

        public struct ExpectedCharacter: LocalizedError, CustomStringConvertible {
            let character: Character

            public var description: String {
                return "Expected character \"\(character)\""
            }
        }
        public struct UnexpectedCharacter: LocalizedError, CustomStringConvertible {
            let character: Character

            public var description: String {
                return "Unexpected character \"\(character)\""
            }
        }
        public struct IncorrectFormat: LocalizedError, CustomStringConvertible {
            let reason: String

            public var description: String {
                return "Incorrect format: \(reason)"
            }
        }
    }

    public func decode(_ script: String) throws -> GameSpecification {

        // Find bracket pairs
        let pairs = try findBracketPairs(in: script)
        // Map into sections
        var sections: [String : [String : String]] = [:]
        for (index, pair) in pairs.enumerated() {
            let otherPairs = pairs.filter({ $0 != pairs[index]})
            if pair.title.lowercased() == "game" {
                if !otherPairs.reduce(true, { $0 && pairs[index].contains($1) }) {
                    throw GameScriptError.IncorrectFormat(reason: "Game section does not contain section titled \"\(pairs[index].title)\".")
                }
            } else {
                if !(otherPairs.reduce(true, { $0 && (!pairs[index].contains($1) || pair.title.lowercased() == "game") })) {
                    throw GameScriptError.IncorrectFormat(reason: "Section titled \"\(pair.title)\" should not contain any other sections.")
                }
            }
            sections[pair.title.lowercased()] = try findArguments(between: pair, in: script, otherPairs: otherPairs)
        }

        return try GameSpecification(sections: ScriptSections(value: sections))
    }

    private struct Pair: Equatable {
        let opening: String.Index
        let closing: String.Index

        let title: Substring

        init(opening: String.Index, closing: String.Index, sourceString: String) throws {
            self.opening = opening
            self.closing = closing
            self.title = try sectionTitle(before: opening, in: sourceString)
        }

        func contains(_ other: Pair) -> Bool {
            return self.closing > other.closing && self.opening < other.opening
        }
    }

    private func findBracketPairs(in string: String) throws -> [Pair] {
        var openings: [String.Index] = []
        var pairs: [Pair] = []
        var startIndex = string.startIndex

        search: while let closingIndex = string[startIndex...].firstIndex(of: "}") {
            if let openingIndex = string[startIndex...].firstIndex(of: "{"),
                openingIndex < closingIndex {
                openings.append(openingIndex)
                startIndex = string.index(after: openingIndex)
            } else if openings.count > 0 {
                startIndex = string.index(after: closingIndex)
                let openingIndex = openings.removeLast()
                let newPair = try Pair(opening: openingIndex, closing: closingIndex, sourceString: string)
                pairs.append(newPair)
            } else {
                throw GameScriptError.ExpectedCharacter(character: "{")
            }
        }
        return pairs
    }

    private static func sectionTitle(before startIndex: String.Index, in text: String) throws -> Substring {
        var searchBeforeIndex = startIndex
        // Index of close bracket
        guard let closeIndex = text[...searchBeforeIndex].lastIndex(of: "]") else { throw GameScriptError.ExpectedCharacter(character: "]") }
        searchBeforeIndex = text.index(before: closeIndex)
        guard let openingIndex = text[...searchBeforeIndex].lastIndex(of: "[") else { throw GameScriptError.ExpectedCharacter(character: "[") }
        return text[text.index(after: openingIndex)..<closeIndex]
    }

    private func findArguments(between bracketPair: Pair, in text: String, otherPairs: [Pair]) throws -> [String : String] {
        var startIndex = text.index(after: bracketPair.opening)
        var attributes: [String : String] = [:]
        search: while let (possibleKey, nextIndex) = try? read(until: "=", in: text, from: startIndex),
            nextIndex < bracketPair.closing {
            for otherPair in otherPairs {
                if bracketPair.contains(otherPair),
                    nextIndex > otherPair.opening && nextIndex < otherPair.closing {
                    startIndex = text.index(after: otherPair.closing)
                    continue search
                }
            }
            let (value, newNextIndex) = try read(until: ";", in: text, from: text.index(after: nextIndex))
            attributes[possibleKey.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)]
                = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            startIndex = text.index(after: newNextIndex)
        }

        return attributes
    }

    private func read(until endCharacter: Character, in text: String, from index: String.Index) throws -> (read: Substring, endIndex: String.Index) {
        guard let nextIndex = text[index...].firstIndex(of: endCharacter) else {
            throw GameScriptError.ExpectedCharacter(character: endCharacter)
        }
        let readCharacters = text[index..<nextIndex]
        // todo: Validation

        return (readCharacters, endIndex: nextIndex)
    }
}

enum LaunchScript {

    enum StartPositionType: Int {
        case fixed = 0
        case random = 1
        case chooseInGame = 2
        case chooseBeforeGame = 3
    }

    struct WritableScriptSection {
        let identifier: ScriptSections.Section
        let nestedSections: [WritableScriptSection]
        let arguments: [String : String]
        var description: String {
            return """
            [\(identifier.description)]
            {
            \(nestedSections.sorted(by: { $0.identifier.description < $1.identifier.description }).map({ $0.description }).joined(separator: "\n"))
            \(arguments.map({ "\($0.key)=\($0.value);"}).sorted().joined(separator: "\n"))
            }
            """
        }
    }

    struct ClientGame {
        let ip: String
        let port: Int
        let username: String
        let password: String
        let doRecordDemo: Bool

        var stringValue: String {
            let gameSectionArguments: [String : String] = [
                "HostIP" : ip,
                "HostPort" : String(port),
                "MyPlayerName" : username,
                "MyPasswd" : password,
                "RecordDemo" : doRecordDemo ? "1" : "0"
            ]

            return WritableScriptSection(identifier: .game, nestedSections: [], arguments: gameSectionArguments).description
        }
    }

    /// A structure that encapsulates information about the game to be hosted by the spring instance to be written in a launchscript
    ///
    /// Documentation has been copied from the [SpringRTS wiki](https://springrts.com/wiki/Script.txt).
    struct HostedGame {
        var stringValue: String {
            var gameSection: [String : String] = [:]

            gameSection["myplayername"] = myPlayerName
            gameSection["mapname"] = mapName
            if let mapHash = mapHash { gameSection["maphash"] = String(mapHash) }
            if let modHash = modHash { gameSection["modhash"] = String(modHash) }
            gameSection["gametype"] = gameType
            if let gameStartDelay = gameStartDelay { gameSection["gamestartdelay"] = String(gameStartDelay) }

            if let startpostype = startPositionType?.rawValue { gameSection["startpostype"] = String(startpostype) }

            gameSection["recorddemo"] = String(doRecordDemo ? 1 : 0)

            gameSection["hosttype"] = hostType
            gameSection["ishost"] = String(isHost ? 1 : 0)

            if let hostIp = hostIp { gameSection["hostip"] = hostIp }
            if let hostPort = hostPort { gameSection["hostport"] = String(hostPort) }

            if let autohost = autohost {
                if let id = autohost.id { gameSection["autohostaccountid"] = String(id) }
                gameSection["autohostname"] = autohost.name
                if let countryCode = autohost.countryCode { gameSection["autohostcountrycode"] = countryCode.rawValue }
                gameSection["autohostport"] = String(autohost.port)
                if let rank = autohost.rank { gameSection["autohostrank"] = String(rank) }
            }

            if let demoFile = demoFile { gameSection["demofile"] = demoFile }

            gameSection["numplayers"] = String(players.count)
            gameSection["numteams"] = String(teams.count)
            gameSection["numallyteams"] = String(allyTeams.count)
            gameSection["numrestrictions"] = String(restrictions.count)


            let playerSections = players.enumerated().map({ WritableScriptSection(identifier: .player(number: $0.offset), nestedSections: [], arguments: $0.element.description) })
            let teamSections = teams.enumerated().map({ WritableScriptSection(identifier: .team(number: $0.offset), nestedSections: [], arguments: $0.element.description) })
            let allyTeamSections = allyTeams.enumerated().map({ WritableScriptSection(identifier: .allyteam(number: $0.offset), nestedSections: [], arguments: $0.element.description) })
            let aiSections = ais.enumerated().map({ WritableScriptSection(identifier: .ai(number: $0.offset), nestedSections: [], arguments: $0.element.description) })

            var formattedRestrictions: [String : String] = [:]
            restrictions.enumerated().forEach({
                formattedRestrictions["limit\($0.offset)"] = String($0.element.value)
                formattedRestrictions["unit\($0.offset)"] = String($0.element.key)
            })

            let writableGameSection = WritableScriptSection(
                identifier: .game,
                nestedSections: [
                    WritableScriptSection(identifier: .restrictions, nestedSections: [], arguments: formattedRestrictions),
                    WritableScriptSection(identifier: .mapOptions, nestedSections: [], arguments: mapOptions),
                    WritableScriptSection(identifier: .modOptions, nestedSections: [], arguments: modOptions)
                ] + playerSections + teamSections + allyTeamSections + aiSections,
                arguments: gameSection
            )
            return writableGameSection.description
        }

        // [GAME] {
        let myPlayerName: String
        let mapName: String // Name of the file
        let mapHash: Int32?
        // SpringLobby doesn't use this value
        //        let gameName: String
        let modHash: Int32?
        let gameType: String // either primary mod NAME, rapid tag name or archive name
        let gameStartDelay: Int? // optional, in seconds, (unsigned int), default: 4
        let startPositionType: StartPositionType? // 0 fixed, 1 random, 2 choose in game, 3 choose before game (see StartPosX)

        let doRecordDemo: Bool // when finally input, 0 for false and 1 for true

        let hostType: String
        let hostIp: String? //
        let hostPort: Int? //
        let isHost: Bool = true // 1 for true, 0 for false


        struct Autohost {
            let id: Int?
            let countryCode: CountryCode?
            let name: String
            let rank: Int?
            let port: Int
        }

        let autohost: Autohost?

        let demoFile: String?

        // [PLAYER0] {
        let players: [Player]
        // }

        let ais: [AI]
        // [AI0] {…} [AIX] {

        let teams: [Team]

        let allyTeams: [AllyTeam]

        // Unit : Max #
        let restrictions: [String : Int]

        let modOptions: [String : String]
        let mapOptions: [String : String]
    }

    /// A structure that encapsulates information about an AI to be written in a launchscript
    struct AI {
        let name: String
        /// The number of the player the AI is associated with
        let host: Int
        let isFromDemo: Bool
        let team: Int
        let shortName: String
        let version: String

        var description: [String : String] {
            return [
                "name" : name,
                "host" : String(host),
                "isfromdemo" : String(isFromDemo ? 1 : 0),
                "team" : String(team),
                "shortname" : shortName,
                "version" : version
            ]
        }
    }

    /// A structure that encapsulates information about a player to be written in a launchscript
    struct Player {
        // [PLAYER0] {
        let username: String
        let accountID: Int?
        let password: String? //
        let countryCode: CountryCode? // Country code of the player.
        let isFromDemo: Bool //

        let rank: Int?
        let skill: String?

        let team: Int? // The team number controlled by the player
        let isSpectator: Bool // 1 for true, 0 for false
        // }

        var description: [String : String] {
            var temp: [String : String] = [
                "name" : username,
                "isfromdemo" : String(isFromDemo ? 1 : 0),
                "spectator" : String(isSpectator ? 1 : 0),
            ]
            if let accountID = accountID { temp["accountid"] = String(accountID) }
            if let password = password { temp["password"] = password }
            if let team = team { temp["team"] = String(team) }
            if let rank = rank { temp["rank"] = String(rank) }
            if let skill = skill { temp["skill"] = skill }
            if let countryCode = countryCode { temp["countrycode"] = countryCode.rawValue }
            return temp
        }
    }

    /// A structure that encapsulates information about a team to be written in a launchscript
    struct Team {
        // [TEAM0] {
        let leader: Int // Player number of the leader
        let allyTeamNumber: Int
        let rgbColor: (red: Float, green: Float, blue: Float)? // r g b in range 0 to 1
        let side: String? // Arm/Core; other sides possible with mods other than BA
        let handicap: Int = 0 // Deprecated, see advantage; but is -100 to 100 - % resource income bonus

        let advantage: Float? // Advantage factor (meta value). Currently only affects incomeMultiplier (below). Valid: [-1.0, FLOAT_MAX]
        let incomeMultiplier: Float? // multiplication factor for collected resources. valid [0.0, FLOAT_MAX]
        let startPosX: Int? // Use these in combination with StartPosType = 3
        let startPosZ: Int? // Range is in map coordinates as returned by UnitSync
        let luaAI: String? // name of the LuaAI that controls this team
        // Either a [PLAYER] or an [AI] is controlling this team, or a LuaAI is set
        // }

        var description: [String : String] {
            var temp: [String : String] = [
                "teamleader" : String(leader),
                "allyteam" : String(allyTeamNumber),
                "handicap" : String(handicap),
            ]
            if let rgbColor = rgbColor { temp["rgbcolor"] = "\(rgbColor.red) \(rgbColor.green) \(rgbColor.blue)" }
            if let side = side { temp["side"] = side }
            if let advantage = advantage { temp["advantage"] = String(advantage) }
            if let incomeMultiplier = incomeMultiplier { temp["incomemultiplier"] = String(incomeMultiplier) }
            if let startPosX = startPosX { temp["startposx"] = String(startPosX) }
            if let startPosZ = startPosZ { temp["startposz"] = String(startPosZ) }
            if let luaAI = luaAI { temp["luaai"] = luaAI }
            return temp
        }
    }

    /// A structure that encapsulates information about an allyteam to be written in a launchscript
    struct AllyTeam {
        var numAllies: Int {
            return allies.count
        }
        // idk
        let allies: [String] = [] // means that this team is allied with the other, not necesarily the reverse (just put each allied allyteam in the array and you can cycle through them, ok?)
        let startRectTop: String?   // Use these in combination with StartPosType=2
        let startRectLeft: String?   //   (ie. select in map)
        let startRectBottom: String? // range is 0-1: 0 is left or top edge,
        let startRectRight: String?  //   1 is right or bottom edge

        var description: [String : String] {
            var temp: [String : String] = [
                "numallies" : String(numAllies)
            ]
            if let startRectTop = startRectTop { temp["startrecttop"] = startRectTop }
            if let startRectBottom = startRectBottom { temp["startrectBottom"] = startRectBottom }
            if let startRectRight = startRectRight { temp["startrectright"] = startRectRight }
            if let startRectLeft = startRectLeft { temp["startrectleft"] = startRectLeft }
            return temp
        }
    }
}
