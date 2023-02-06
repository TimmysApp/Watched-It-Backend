//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Vapor

enum CommonError {
    case unsuportedMethod, invalidContent, emptyFile, emptyBody(String), invalidPerson, emptyParameter(String)
}

extension CommonError: WatchedItError {
    var description: String {
        switch self {
            case .unsuportedMethod:
                return "The request method used isn't supported! Either use GET for the current user, or POST to query users using an id/username."
            case .invalidContent:
                return "The content requested does not exist!"
            case .emptyFile:
                return "The data provided is empty!"
            case .emptyBody(let string):
                return "The request body is invalid! \(string)"
            case .invalidPerson:
                return "The boy with the requested id does not exist!"
            case .emptyParameter(let string):
                return "The request parameters are invalid! \(string)"
        }
    }
    var status: HTTPResponseStatus {
        switch self {
            case .unsuportedMethod:
                return .methodNotAllowed
            case .invalidContent:
                return .noContent
            case .emptyFile:
                return .unsupportedMediaType
            case .emptyBody, .emptyParameter:
                return .badRequest
            case .invalidPerson:
                return .notAcceptable
        }
    }
    var reason: String {
        switch self {
            case .unsuportedMethod:
                return "Unsuported Method"
            case .invalidContent:
                return "Invalid Content"
            case .emptyFile:
                return "Empty Data"
            case .emptyBody:
                return "Invalid Body"
            case .invalidPerson:
                return "Invalid Boy"
            case .emptyParameter:
                return "Invalid Parameters"
        }
    }
}
