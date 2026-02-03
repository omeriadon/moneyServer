import Crypto
import Fluent
import Vapor

struct UserController: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		let users = routes.grouped("users")
		users.post("signup", use: signup)
		users.post("login", use: login)

		let tokenProtected = users.grouped(UserToken.authenticator(), User.guardMiddleware())
		tokenProtected.get("me", use: me)
		tokenProtected.post("logout", use: logout)
		tokenProtected.delete("me", use: delete)
		tokenProtected.patch("me", use: update)
	}

	func signup(req: Request) async throws -> UserTokenResponseDTO {
		try UserCreateDTO.validate(content: req)
		let create = try req.content.decode(UserCreateDTO.self)

		if try await User.query(on: req.db)
			.filter(\.$email == create.email.lowercased())
			.first() != nil
		{
			throw Abort(.conflict, reason: "A user with this email already exists.")
		}

		let user = try User(
			id: nil,
			email: create.email.lowercased(),
			passwordHash: Bcrypt.hash(create.password),
			firstName: create.firstName
		)

		try await user.save(on: req.db)

		let token = try user.generateToken()
		try await token.save(on: req.db)

		return UserTokenResponseDTO(
			token: token.value,
			user: UserDTO(id: user.id, firstName: user.firstName, email: user.email)
		)
	}

	func login(req: Request) async throws -> UserTokenResponseDTO {
		let loginDTO = try req.content.decode(UserLoginDTO.self)

		guard let user = try await User.query(on: req.db)
			.filter(\.$email == loginDTO.email.lowercased())
			.first()
		else {
			throw Abort(.unauthorized, reason: "Invalid email or password.")
		}

		guard try Bcrypt.verify(loginDTO.password, created: user.passwordHash) else {
			throw Abort(.unauthorized, reason: "Invalid email or password.")
		}

		let token = try user.generateToken()
		try await token.save(on: req.db)

		return UserTokenResponseDTO(
			token: token.value,
			user: UserDTO(id: user.id, firstName: user.firstName, email: user.email)
		)
	}

	func logout(req: Request) async throws -> HTTPStatus {
		let token = try req.auth.require(UserToken.self)
		try await token.delete(on: req.db)
		return .noContent
	}

	func me(req: Request) async throws -> UserDTO {
		let user = try req.auth.require(User.self)
		return UserDTO(id: user.id, firstName: user.firstName, email: user.email)
	}

	func delete(req: Request) async throws -> HTTPStatus {
		let user = try req.auth.require(User.self)

		try await UserToken.query(on: req.db)
			.filter(\.$user.$id == user.requireID())
			.delete()

		try await Transaction.query(on: req.db)
			.filter(\.$user.$id == user.requireID())
			.delete()

		try await user.delete(on: req.db)

		return .ok
	}

	func update(req: Request) async throws -> UserDTO {
		let user = try req.auth.require(User.self)
		let update = try req.content.decode(UserUpdateDTO.self)

		if let firstName = update.firstName {
			user.firstName = firstName
		}

		if let email = update.email?.lowercased() {
			if let existing = try await User.query(on: req.db)
				.filter(\.$email == email)
				.first(),
				existing.id != user.id
			{
				throw Abort(.conflict, reason: "A user with this email already exists.")
			}
			user.email = email
		}

		if let password = update.password {
			user.passwordHash = try Bcrypt.hash(password)
		}

		try await user.save(on: req.db)

		return UserDTO(id: user.id, firstName: user.firstName, email: user.email)
	}
}
