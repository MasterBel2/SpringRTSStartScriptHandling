//
//  AI.swift
//  BelieveAndRise
//
//  Created by MasterBel2 on 15/4/20.
//  Copyright © 2020 MasterBel2. All rights reserved.
//

import Foundation

/// Details about an AI that will control the units of a team.
public struct AI: Equatable {
    /// An integer for uniquely identifying the AI within the startscript.
    public let scriptID: Int
    public let name: String
    /// The ID of the player providing the AI
    public let hostID: Int
    /// The AI's shortName as given by Unitsync
    public let shortName: String
    /// The AI's version as given by unitsync
    public let version: String

    /// Whether or not the AI come from a demo.
    public let isFromDemo: Bool

    public init(scriptID: Int, name: String, hostID: Int, shortName: String, version: String, isFromDemo: Bool) {
        self.scriptID = scriptID
        self.name = name
        self.hostID = hostID
        self.shortName = shortName
        self.version = version
        self.isFromDemo = isFromDemo
    }
}
