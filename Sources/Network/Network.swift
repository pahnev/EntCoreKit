//
//  File.swift
//  
//
//  Created by Kirill Pahnev on 14.2.2023.
//

import Foundation

public enum HTTPMethod {
    case GET
    case POST
}

public struct Network {
    public init(urlSession: URLSession = .shared) {

    }
    public func getSomethingOf<T: Decodable>(type: T.Type) -> T {
        fatalError("TODO")
    }
}
