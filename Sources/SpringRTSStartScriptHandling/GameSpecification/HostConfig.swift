//
//  HostConfig.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation
import CountryCode
import ServerAddress

/// A set of information about the host required by the engine to launch a game.
public struct HostConfig: Equatable {
    /// The unique ID associated with the host's account.
    public let userID: Int?
    /// The host's username.
    public let username: String
    /// Information about the host program.
    public let type: HostType
    ///
    public let address: ServerAddress?
    #warning("FIXME - this probably shouldn't be optional. Prefer to have some kind of an enum handling?")
    /// The lobby rank of the host account.
    public let rank: Int?
    /// The country code describing the location from which the host connects.
    public let countryCode: CountryCode?

    public init(userID: Int?, username: String, type: HostType, address: ServerAddress?, rank: Int?, countryCode: CountryCode?) {
        self.userID = userID
        self.username = username
        self.type = type
        self.address = address
        self.rank = rank
        self.countryCode = countryCode
    }

    /// A set of cases describing the game is being hosted.
    public enum HostType: Equatable {
        public static func == (lhs: HostConfig.HostType, rhs: HostConfig.HostType) -> Bool {
            switch lhs {
            case .autohost(let (programNameLHS, portLHS)):
                switch rhs {
                case .autohost(let (programNameRHS, portRHS)):
                    return programNameLHS == programNameRHS && portLHS == portRHS
                default:
                    return false
                }
            case .user(let lobbyNameLHS):
                switch rhs {
                case .user(let lobbyNameRHS):
                    return lobbyNameLHS == lobbyNameRHS
                default:
                    return false
                }
            }
        }

        /// Indicates that the host is an autonomous program.
        case autohost((programName: String, port: Int))
        /// Indicates that the host is a user with a lobby client.
        case user(lobbyName: String)

        
    }
}
