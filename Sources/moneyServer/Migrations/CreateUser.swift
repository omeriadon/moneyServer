import Fluent

struct CreateUser: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("users")
			.id()
			.field("email", .string, .required)
			.field("password_hash", .string, .required)
			.field("first_name", .string, .required)
			.unique(on: "email")
			.create()
	}

	func revert(on database: any Database) async throws {
		try await database.schema("users").delete()
	}
}
