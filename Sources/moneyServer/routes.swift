import Vapor

func routes(_ app: Application) throws {
    app.get("health") { _ -> HealthResponse in
        HealthResponse(
            status: "ok",
            uptime: Int(ProcessInfo.processInfo.systemUptime)
        )
    }

    try app.register(collection: TransactionController())
    try app.register(collection: UserController())
}
