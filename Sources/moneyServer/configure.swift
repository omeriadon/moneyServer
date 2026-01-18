import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

public func configure(_ app: Application) async throws {
	// app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	let postgresConfig = try SQLPostgresConfiguration(
		hostname: Environment.get("DATABASE_HOST") ?? "localhost",
		port: Environment.get("DATABASE_PORT").flatMap(Int.init) ?? SQLPostgresConfiguration.ianaPortNumber,
		username: Environment.get("DATABASE_USERNAME") ?? "adon",
		password: Environment.get("DATABASE_PASSWORD") ?? "supersecure",
		database: Environment.get("DATABASE_NAME") ?? "moneyserver",
		tls: .prefer(.init(configuration: .clientDefault))
	)

	app.databases.use(
		.postgres(
			configuration: postgresConfig,
			sqlLogLevel: .info
		),
		as: .psql
	)

	app.migrations.add(CreateUser())
	app.migrations.add(CreateTransaction())
	app.migrations.add(CreateUserToken())

	// register routes
	try routes(app)
}
