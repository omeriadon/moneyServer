import Vapor

func routes(_ app: Application) throws {
	app.get("health") { _ -> HealthDTO in
		HealthDTO(
			status: "ok",
			uptime: Int(ProcessInfo.processInfo.systemUptime)
		)
	}

	try app.register(collection: TransactionController())
	try app.register(collection: UserController())
}
