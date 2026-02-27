import Fluent

struct CreateGoal: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("goals")
			.id()
			.field("name", .string, .required)
			.field("description", .string, .required)
			.field("goal_amount", .double, .required)
			.field("user_id", .uuid, .required, .references("users", "id"))
			.field("date_created", .datetime)
			.field("date_updated", .datetime)
			.create()
	}

	func revert(on database: any Database) async throws {
		try await database.schema("goals").delete()
	}
}
