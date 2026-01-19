import Fluent

struct MakeTransactionDouble: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("transactions")
			.updateField("change", .double)
			.update()
	}

	func revert(on database: any Database) async throws {
		try await database.schema("transactions")
			.updateField("change", .int)
			.update()
	}
}
