//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Fluent
import Vapor
import JWT

struct JWTBearerAuthenticator: AsyncJWTAuthenticator {
    func authenticate(jwt: SessionToken, for request: Request) async throws {
        do {
            try jwt.verify(using: request.application.jwt.signers.get()!)
        }catch {
            throw AuthenticationError.invalidToken
        }
        guard let user = try? await UserModel
            .find(jwt.userId, on: request.db) else {
            throw AuthenticationError.invalidUser
        }
        guard user.loggedIn else {
            throw AuthenticationError.invalidToken
        }
        request.auth.login(user)
    }
}

struct SessionToken: Content, Authenticatable, JWTPayload {
    var userId: UUID
    var expiration: ExpirationClaim
    init(userId: UUID) {
        self.userId = userId
        self.expiration = ExpirationClaim(value: Date().addingTimeInterval(60 * 100))
    }
    func verify(using signer: JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
