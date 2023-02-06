import Fluent

struct CreateUser1: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(UserModel.schema)
        //            .delete()
            .id()
            .field("username", .string, .required)
            .field("password_hash", .string, .required)
            .field("device", .string, .required)
            .field("email", .string, .required)
            .field("logged_in", .bool, .required)
            .field("email_verified", .bool, .required)
            .field("creation_date", .datetime, .required)
            .field("update_date", .datetime, .required)
            .field("full_name", .string)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(UserModel.schema).delete()
    }
}
