//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Fluent

struct CreateToken: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(TokenModel.schema)
        //            .delete()
            .id()
            .field("user_id", .uuid, .references("users", "id"))
            .field("value", .string, .required)
            .unique(on: "value")
            .field("source", .int, .required)
            .field("creation_date", .datetime, .required)
            .field("expiry_date", .datetime)
            .field("update_date", .datetime)
            .create()
    }
    func revert(on database: Database) async throws {
        try await database.schema(TokenModel.schema).delete()
    }
}
