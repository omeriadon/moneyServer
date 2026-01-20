import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

public func configure(_ app: Application) async throws {
	// app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	let postgresConfig = SQLPostgresConfiguration(
		hostname: Environment.get("DATABASE_HOST") ?? "localhost",
		port: Environment.get("DATABASE_PORT").flatMap(Int.init)!,
		username: Environment.get("DATABASE_USERNAME")!,
		password: Environment.get("DATABASE_PASSWORD"),
		database: Environment.get("DATABASE_NAME"),
		tls: .disable
	)

	app.http.server.configuration.port = 6776

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
	app.migrations.add(MakeTransactionDouble())

	try routes(app)
}
