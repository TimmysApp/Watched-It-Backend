import Fluent
import Vapor
import JWT
import WatchedItModels

final class UserModel: Model {
//MARK: - Fields
    @ID(key: .id) var id: UUID?
    @Field(key: "username") var username: String
    @Field(key: "password_hash") var passwordHash: String
    @Field(key: "device") var device: String
    @Field(key: "email") var email: String
    @OptionalField(key: "full_name") var fullName: String?
    @Field(key: "logged_in") var loggedIn: Bool
    @Field(key: "email_verified") var emailVerified: Bool
    @Timestamp(key: "creation_date", on: .create) var creationDate: Date?
    @Timestamp(key: "update_date", on: .update) var updateDate: Date?
    //MARK: - Initializer
    init() {
    }
    init(id: UUID? = nil, passwordHash: String, device: String, email: String) {
        self.id = id
        self.username = email
        self.passwordHash = passwordHash
        self.device = device
        self.email = email
        self.loggedIn = false
        self.emailVerified = false
    }
    //MARK: - Schema
    static let schema = "users"
}

//MARK: - Functions
extension UserModel {
    static func create(from credentials: UserCredentials) throws -> UserModel {
        let model = UserModel(passwordHash: try Bcrypt.hash(credentials.password), device: credentials.device ?? "", email: credentials.email)
        return model
    }
    func token(db: Database) async throws -> TokenModel {
        guard let id = id, let user = try? await TokenModel.query(on: db).filter(\.$user.$id == id).first() else {
            throw AuthenticationError.invalidUser
        }
        return user
    }
    func generateAccessToken(_ app: Application) throws -> (String, Date) {
        guard let id = id else {
            throw AuthenticationError.invalidUser
        }
        guard let token = try? app.jwt.signers.get(kid: .publicES)!.sign(SessionToken(userId: id)) else {
            throw AuthenticationError.tokenCreation
        }
        return (token, Date().addingTimeInterval(60 * 15))
    }
    func generateRefreshToken(db: Database, from source: SessionSource) async throws -> TokenModel {
        let expiryDate = Calendar(identifier: .gregorian).date(byAdding: .day, value: 15, to: Date())
        guard let token = try? TokenModel(userId: requireID(), token: [UInt8].random(count: 200).base64, source: source, expiryDate: expiryDate) else {
            throw AuthenticationError.refreshTokenCreation
        }
        do {
            try await token.save(on: db)
        }catch {
            throw AuthenticationError.refreshTokenCreation
        }
        return token
    }
    func generateSession(db: Database, app: Application, source: SessionSource, oldToken: TokenModel? = nil) async throws -> AuthSession {
        guard id != nil else {
            throw AuthenticationError.invalidUser
        }
        let accessToken = try generateAccessToken(app)
        var refreshToken: TokenModel!
        if source == .signup {
            refreshToken = try await generateRefreshToken(db: db, from: source)
        }else if let oldToken = oldToken {
            refreshToken = try await oldToken.updateToken(db: db)
        }else {
            refreshToken = try await token(db: db).updateToken(db: db)
        }
        return AuthSession(token: accessToken.0, refreshToken: refreshToken.value, tokenExpiry: accessToken.1, refreshTokenExpiry: refreshToken.expiryDate ?? Date())
    }
}

//MARK: - ModelAuthenticatable
extension UserModel: ModelAuthenticatable {
    static let usernameKey = \UserModel.$username
    static let passwordHashKey = \UserModel.$passwordHash
    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
