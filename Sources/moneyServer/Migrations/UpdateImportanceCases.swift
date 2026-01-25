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
	}

	func revert(on database: any Database) async throws {
		let sql = database as! any SQLDatabase
		try await sql.raw("""
			UPDATE transactions
			SET importance = 'emergent'
			WHERE importance = 'emergency';
		""").run()
	}
}
