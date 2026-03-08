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

		// Normalize weird persisted values like '"active"' or "'active'" safely.
		try await sql.raw("""
			UPDATE goals
			SET status = lower(regexp_replace(status, '[^a-zA-Z_]', '', 'g'))
			WHERE status IS NOT NULL;
		""").run()

		// Fallback any unknown status to active.
		try await sql.raw("""
			UPDATE goals
			SET status = 'active'
			WHERE status NOT IN ('active', 'paused', 'completed', 'archived');
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
