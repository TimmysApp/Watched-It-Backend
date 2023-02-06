import Fluent
import Vapor

func routes(_ app: Application) throws {
    let api = app.grouped("api").grouped("v1")
    try api.register(collection: AuthenticationController())
}
