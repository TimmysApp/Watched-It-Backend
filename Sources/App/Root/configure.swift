import Fluent
import FluentPostgresDriver
import Vapor
import JWT

public func configure(_ app: Application) throws {
    //MARK: - Database
    if let urlString = Environment.get("DATABASE_URL"), var postgressConfig = PostgresConfiguration(url: urlString) {
        var tlsConfig = TLSConfiguration.makeClientConfiguration()
        tlsConfig.certificateVerification = .none
        postgressConfig.tlsConfiguration = tlsConfig
        app.databases.use(.postgres(configuration: postgressConfig), as: .psql)
    }else {
        app.databases.use(.postgres(
            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
            database: Environment.get("DATABASE_NAME") ?? "vapor_database"
        ), as: .psql)
    }
//MARK: - Middleware
    app.middleware = .init()
    app.middleware.use(WatchedItErrorMiddleWare(), at: .end)
    //    try app.jwt.signers.use(AuthConfigurations.esPrivateSigner(app: app), kid: .privateES)
    try app.jwt.signers.use(AuthConfigurations.esPublicSigner(app: app), kid: .publicES)
//MARK: - Migrations
    app.migrations.add(CreateUser1())
    app.migrations.add(CreateToken())
    if app.environment == .development {
        try app.autoMigrate().wait()
    }
//MARK: - Routes
    try routes(app)
    app.routes.defaultMaxBodySize = "2mb"
}
