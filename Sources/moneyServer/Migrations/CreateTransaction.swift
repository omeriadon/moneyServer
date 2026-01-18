import Fluent

struct CreateTransaction: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("transactions")
			.id()
			.field("change", .int, .required)
			.field("title", .string, .required)
			.field("description", .string, .required)
			.field("importance", .string, .required)
			.field("user_id", .uuid, .required, .references("users", "id"))
			.field("date_created", .datetime)
			.field("date_updated", .datetime)
			.create()
	}

	func revert(on database: any Database) async throws {
		try await database.schema("transactions").delete()
	}
}
