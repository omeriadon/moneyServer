import Fluent

struct CreateTransaction: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("transactions")
			.id()
			.field("change", .int, .required)
			.field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
			.create()
	}

	func revert(on database: any Database) async throws {
		try await database.schema("transactions").delete()
	}
}
