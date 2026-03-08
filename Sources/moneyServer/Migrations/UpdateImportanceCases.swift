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

struct AddGoalStatus: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("goals")
			.field("status", .string, .required, .sql(.default("active")))
			.update()

		let sql = database as! any SQLDatabase
		try await sql.raw("""
			UPDATE goals
			SET status = 'active'
			WHERE status IS NULL;
		""").run()
	}

	func revert(on database: any Database) async throws {
		try await database.schema("goals")
			.deleteField("status")
			.update()
	}
}

struct NormalizeGoalStatusValues: AsyncMigration {
	func prepare(on database: any Database) async throws {
		let sql = database as! any SQLDatabase
		try await sql.raw("""
			UPDATE goals
			SET status = trim(both E'\"' from trim(both '\'' from status));
		""").run()

		try await sql.raw("""
			ALTER TABLE goals
			ALTER COLUMN status SET DEFAULT 'active';
		""").run()
	}

	func revert(on database: any Database) async throws {
		let sql = database as! any SQLDatabase
		try await sql.raw("""
			ALTER TABLE goals
			ALTER COLUMN status SET DEFAULT 'active';
		""").run()
	}
}
