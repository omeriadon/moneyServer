import Fluent
import SQLKit

struct RenameImportanceEmergentToEmergency: AsyncMigration {
	func prepare(on database: any Database) async throws {
		let sql = database as! any SQLDatabase

		try await sql.raw("""
			UPDATE transactions
			SET importance = 'emergency'
			WHERE importance = 'emergent';
		""").run()

		_ = try await database.enum("importance_enum")
			.deleteCase("emergent")
			.update()

		_ = try await database.enum("importance_enum")
			.case("emergency")
			.update()
	}

	func revert(on database: any Database) async throws {
		let sql = database as! any SQLDatabase

		try await sql.raw("""
			UPDATE transactions
			SET importance = 'emergent'
			WHERE importance = 'emergency';
		""").run()

		_ = try await database.enum("importance_enum")
			.deleteCase("emergency")
			.update()

		_ = try await database.enum("importance_enum")
			.case("emergent")
			.update()
	}
}
