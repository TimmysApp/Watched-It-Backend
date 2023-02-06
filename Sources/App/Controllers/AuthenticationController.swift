import Vapor
import Fluent
import JWT
import SendinBlueMailer

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let usersRoute = routes.grouped("authentication")
        usersRoute.post("registration", use: register)
        usersRoute.post("checkEmail", use: checkEmail)
        usersRoute.post("refreshToken", use: refresh)
        let passwordProtected = usersRoute.grouped(UserModel.authenticator())
        passwordProtected.post("signin", use: signIn)
        let authProtected = usersRoute.grouped(JWTBearerAuthenticator())
        authProtected.post("signout", use: signOut)
    }
//MARK: - Check Username
    func checkEmail(req: Request) async throws -> SendableResponse<EmptyBody> {
        try SearchableUser.validate(content: req)
        guard let username = try? req.content.decode(SearchableUser.self) else {
            throw CommonError.emptyBody("You need to provide an `email`.")
        }
        let user = await username.user(db: req.db)
        guard user == nil else {
            throw AuthenticationError.usernameTaken
        }
        return SendableResponse(status: .ok, visible: .success())
    }
//MARK: - Register
    func register(req: Request) async throws -> SendableResponse<AuthSession> {
        try UserCredentials.validate(content: req)
        guard let userSignUp = try? req.content.decode(UserCredentials.self) else {
            throw CommonError.emptyBody("You need to provide a `username`, a `password`, a `device` & a `referallCode`.")
        }
        let userExist = await userSignUp.exists(db: req.db)
        guard !userExist else {
            throw AuthenticationError.usernameTaken
        }
        let user = try UserModel.create(from: userSignUp)
        try await user.create(on: req.db)
        let session = try await user.generateSession(db: req.db, app: req.application, source: .signup)
        return SendableResponse(status: .ok, visible: .success(session))
    }
//MARK: - Send Verifications
    func sendVerification(req: Request) async throws -> SendableResponse<EmptyBody> {
        try SearchableUser.validate(content: req)
        guard let email = try? req.content.decode(SearchableUser.self) else {
            throw CommonError.emptyBody("Make sure you are sending the Email using the key 'email'.")
        }
        guard let user = await email.user(db: req.db) else {
            throw AuthenticationError.invalidUser
        }
        let otp = try await TokenModel.generateOTP(for: user.requireID(), on: req.db)
        let sender = Individual(name: "Fortune Me", email: "no-reply@fortuneme.com")
        let receiver = Individual(name: user.fullName ?? "", email: user.email)
        let verificationEmail = SIBEmail(sender: sender, to: [receiver], subject: "Email Verification", htmlContent: """
                 <html>
                 <body>
                 <p>Your otp is \(otp)</p>
                 </body>
                 </html>
                 """)
        try await req.application.mailClient.send(email: verificationEmail, on: req.eventLoop).get()
        return FResponse(status: .ok, visible: .success())
    }
//MARK: - Verify
    func verify(req: Request) async throws -> SendableResponse<String> {
        try SearchableUser.validate(content: req)
        guard let verification = try? req.content.decode(OTPVerification.self) else {
            throw CommonError.missing("Make sure you are sending the Email using the key 'email' & the OTP using the key 'otp'.")
        }
        guard let user = await verification.user(db: req.db) else {
            throw AuthenticationError.invalidUser
        }
        try await TokenModel.validate(otp: verification.otp, userID: try user.requireID(), on: req.db)
        user.verified = true
        try await user.update(on: req.db)
        return FResponse(status: .ok, visible: .success())
    }
//MARK: - Sign In
    func signIn(req: Request) async throws -> SendableResponse<AuthSession> {
        do {
            try UserCredentials.validate(content: req)
            let credentials = try req.content.decode(UserCredentials.self)
            guard let user = await credentials.user(db: req.db), ((try? user.verify(password: credentials.password)) != nil) else {
                throw AuthenticationError.invalidUser
            }
            user.loggedIn = true
            try await user.update(on: req.db)
            let session = try await user.generateSession(db: req.db, app: req.application, source: .signin, oldToken: nil)
            return SendableResponse(status: .ok, visible: .success(session))
        }catch {
            throw CommonError.emptyBody("You need to provide a `username` & a `password`.")
        }
    }
//MARK: - Refresh Token
    func refresh(req: Request) async throws -> SendableResponse<AuthSession> {
        try RefreshTokenCredentials.validate(content: req)
        guard let refreshTokenCredentials = try? req.content.decode(RefreshTokenCredentials.self) else {
            throw CommonError.emptyBody("You need to provide a `refreshToken`.")
        }
        guard let refreshToken = try? await TokenModel.query(on: req.db).filter(\.$value == refreshTokenCredentials.refreshToken).first() else {
            throw AuthenticationError.invalidRefreshToken
        }
        guard refreshToken.isValid else {
            throw AuthenticationError.expiredRefreshToken
        }
        let user = try await refreshToken.user(db: req.db)
        let session = try await user.generateSession(db: req.db, app: req.application, source: .refresh, oldToken: refreshToken)
        return SendableResponse(status: .ok, visible: .success(session))
    }
//MARK: - Sign Out
    func signOut(req: Request) async throws -> SendableResponse<EmptyBody> {
        let user = try req.auth.require(UserModel.self)
        user.loggedIn = false
        try await user.update(on: req.db)
        return SendableResponse(status: .accepted, visible: .success())
    }
}
