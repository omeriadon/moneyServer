import Crypto
import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")
        users.post("signup", use: signup)

        // Password login
        let passwordProtected = users.grouped(User.authenticator(), User.guardMiddleware())
        passwordProtected.post("login", use: login)

        // Token-protected routes
        let tokenProtected = users.grouped(UserToken.authenticator(), User.guardMiddleware())
        tokenProtected.get("me", use: me)
        tokenProtected.post("logout", use: logout)
    }

    // MARK: - Signup

    func signup(req: Request) async throws -> UserDTO {
        try UserCreateDTO.validate(content: req)
        let create = try req.content.decode(UserCreateDTO.self)

        let user = try User(
            id: nil,
            email: create.email.lowercased(),
            passwordHash: Bcrypt.hash(create.password),
            firstName: create.firstName
        )

        do {
            try await user.save(on: req.db)
        } catch {
            req.logger.error("\(String(reflecting: error))")
            throw error
        }

        return UserDTO(id: user.id, firstName: user.firstName, email: user.email)
    }

    // MARK: - Login

    func login(req: Request) async throws -> UserToken {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token
    }

    // MARK: - Logout

    func logout(req: Request) async throws -> HTTPStatus {
        let token = try req.auth.require(UserToken.self)
        try await token.delete(on: req.db)
        return .noContent
    }

    // MARK: - Current user

    func me(req: Request) async throws -> UserDTO {
        let user = try req.auth.require(User.self)
        return UserDTO(id: user.id, firstName: user.firstName, email: user.email)
    }
}
