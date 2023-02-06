//
//  File.swift
//  
//
//  Created by Joe Maghzal on 05/02/2023.
//

import Vapor
import Fluent
import JWT
import WatchedItModels

//MARK: - Validatable
extension RefreshTokenCredentials: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("refreshToken", as: String.self, is: !.empty)
    }
}

extension UserCredentials: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("password", as: String.self, is: .count(8...))
    }
}

extension SearchableUser: Validatable {
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
    }
}

extension OTPVerification: Content, Validatable {
    func user(db: Database) async -> UserModel? {
        return try? await UserModel.query(on: db)
            .filter(\.$email == email)
            .first()
    }
    public static func validations(_ validations: inout Validations) {
        validations.add("email", as: String.self, is: .email)
        validations.add("otp", as: String.self, is: .count(6...6))
    }
}

//MARK: - Functions
extension UserCredentials {
    func exists(db: Database) async -> Bool {
        return (await user(db: db)) != nil
    }
    func user(db: Database) async -> UserModel? {
        return try? await UserModel.query(on: db)
            .filter(\.$email == email)
            .first()
    }
}

extension SearchableUser: Content {
    func user(db: Database) async -> UserModel? {
        if let username {
            return try? await UserModel.query(on: db)
                .filter(\.$username == username)
                .first()
        }else if let id {
            return try? await UserModel.query(on: db)
                .filter(\.$id == id)
                .first()
        }
        return nil
    }
}
