//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//


import Vapor
import Fluent
import JWT

final class TokenModel: Model {
//MARK: - Fields
    @ID(key: "id") var id: UUID?
    @Parent(key: "user_id") var user: UserModel
    @Field(key: "value") var value: String
    @Field(key: "type") var type: TokenType
    @Field(key: "source") var source: SessionSource
    @Field(key: "expiry_date") var expiryDate: Date?
    @Timestamp(key: "creation_date", on: .create) var creationDate: Date?
    @Timestamp(key: "update_date", on: .update) var updatedDate: Date?
    //MARK: - Initializer
    init() {
    }
    init(id: UUID? = nil, userId: UserModel.IDValue, token: String,
         source: SessionSource, expiryDate: Date?) {
        self.id = id
        self.$user.id = userId
        self.value = token
        self.source = source
        self.expiryDate = expiryDate
    }
    init(id: UUID? = nil, userId: UserModel.IDValue, otp: String, expiryDate: Date?) {
        self.id = id
        self.$user.id = userId
        self.value = otp
        self.expiryDate = expiryDate
        self.type = .otp
    }
    //MARK: - Schema
    static let schema = "tokens"
}

//MARK: - Functions
extension TokenModel {
    func user(db: Database) async throws -> UserModel {
        guard let user = try? await User.query(on: db).filter(\.$id == $user.id).first() else {
            throw AuthenticationError.invalidToken
        }
        return user
    }
    func updateToken(db: Database) async throws -> TokenModel {
        self.value = [UInt8].random(count: 200).base64
        self.expiryDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 15, to: Date())
        do {
            try await self.update(on: db)
            return self
        }catch {
            throw AuthenticationError.refreshTokenCreation
        }
    }
    static func generateOTP(for userID: UserModel.IDValue, on db: Database) async throws -> String {
        let newOTP = "\(Int.random(in: 100000...999999))"
        let newDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 1, to: Date())
        let newToken = TokenModel(userId: userID, otp: newOTP, expiryDate: newDate)
        try await newToken.save(on: db)
        return newOTP
    }
    static func validate(otp: String, userID: UserModel.IDValue, on db: Database) async throws {
        guard let otp = try? await TokenModel.query(on: db).filter(\.$value == otp).filter(\.$user.$id == userID).first() else {
            throw AuthenticationError.invalidOTP
        }
        guard otp.isValid else {
            throw AuthenticationError.expiredOTP
        }
    }
}

//MARK: - ModelTokenAuthenticatable
extension TokenModel: ModelTokenAuthenticatable {
    static let valueKey = \TokenModel.$value
    static let userKey = \TokenModel.$user
    var isValid: Bool {
        guard let expiryDate = expiryDate else {
            return true
        }
        return expiryDate > Date()
    }
}

enum SessionSource: Int, Content {
    case signup, signin, refresh
}

enum TokenType: Int, Content {
    case otp, token
}
