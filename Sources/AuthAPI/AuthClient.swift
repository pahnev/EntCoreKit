//
//  File.swift
//  
//
//  Created by Kirill Pahnev on 14.2.2023.
//

import Foundation
import Network

public struct Token: Decodable {}

public struct AuthClient {
    let network: Network

    public init(network: Network = Network()) {
        self.network = network
    }
    public func getSSOTokens() -> Token {
        network.getSomethingOf(type: Token.self)
    }
}
