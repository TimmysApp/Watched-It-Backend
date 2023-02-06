//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Vapor

enum AuthenticationError {
    case usernameTaken, invalidUser
    //MARK: - Bearer Token
    case tokenCreation, invalidToken
    //MARK: - RefreshToken
    case refreshTokenCreation, invalidRefreshToken, expiredRefreshToken
}

//MARK: - AidieError
extension AuthenticationError: WatchedItError {
    var description: String {
        switch self {
            case .usernameTaken:
                return "Please choose another username as the requested username is already in use!"
            case .invalidUser:
                return "Could not find user. Please check your credentials or head to the registration page to get started!"
            //MARK: - Bearer Token
            case .tokenCreation:
                return "Could not create an Access Token. Please try again!"
            case .invalidToken:
                return "The provided Access Token is invalid!"
            //MARK: - RefreshToken
            case .refreshTokenCreation:
                return "Could not create a Refresh Token. Please try again!"
            case .invalidRefreshToken:
                return "The provided Refresh Token is invalid!"
            case .expiredRefreshToken:
                return "The provided Refresh Token has been expired!"
        }
    }
    var status: HTTPResponseStatus {
        switch self {
            case .usernameTaken:
                return .conflict
            case .invalidUser:
                return .notFound
            //MARK: - Bearer Token
            case .tokenCreation:
                return .expectationFailed
            case .invalidToken:
                return .unauthorized
            //MARK: - RefreshToken
            case .refreshTokenCreation:
                return .forbidden
            case .invalidRefreshToken:
                return .unauthorized
            case .expiredRefreshToken:
                return .forbidden
        }
    }
    var reason: String {
        switch self {
            case .usernameTaken:
                return "Username already Exists"
            case .invalidUser:
                return "Invalid User"
                //MARK: - Bearer Token
            case .tokenCreation:
                return "Access Token Error"
            case .invalidToken:
                return "Invalid Access Token"
                //MARK: - RefreshToken
            case .refreshTokenCreation:
                return "Access Token Error"
            case .invalidRefreshToken:
                return "Invalid Refresh Token"
            case .expiredRefreshToken:
                return "Refresh Token Expired"
        }
    }
}

protocol WatchedItError: AbortError {
    var reason: String {get}
    var description: String {get}
    var status: HTTPStatus {get}
}
