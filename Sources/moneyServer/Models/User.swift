import Fluent
import struct Foundation.UUID
import Vapor

final class User: Model, Authenticatable, @unchecked Sendable {
	static let schema = "users"

	@ID(key: .id)
	var id: UUID?

	@Field(key: "email")
	var email: String

	@Field(key: "first_name")
	var firstName: String

	@Field(key: "password_hash")
	var passwordHash: String

	@Children(for: \.$user)
	var transactions: [Transaction]

	init() {}

	init(id: UUID? = nil, email: String, passwordHash: String, firstName: String) {
		self.id = id
		self.email = email
		self.passwordHash = passwordHash
		self.firstName = firstName
	}
}

extension User {
	func generateToken() throws -> UserToken {
		try .init(
			value: [UInt8].random(count: 16).base64,
			userID: requireID()
		)
	}
}

extension User: ModelAuthenticatable {
	static var usernameKey: KeyPath<User, FieldProperty<User, String>> { \.$email }
	static var passwordHashKey: KeyPath<User, FieldProperty<User, String>> { \.$passwordHash }

	func verify(password: String) throws -> Bool {
		try Bcrypt.verify(password, created: passwordHash)
	}
}
