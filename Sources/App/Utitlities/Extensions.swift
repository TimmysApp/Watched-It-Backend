//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Vapor
import Fluent

extension HTTPHeaders {
    static let defaultHeaders: HTTPHeaders = {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        return headers
    }()
}

extension Equatable {
    func update(_ root: inout Self?) {
        if root != self {
            root = self
        }
    }
    func update(_ root: inout Self) {
        if root != self {
            root = self
        }
    }
}


extension Sequence {
    func asyncMap<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()
        for element in self {
            try await values.append(transform(element))
        }
        return values
    }
}
