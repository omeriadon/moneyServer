import Vapor

struct HealthResponse: Content {
	let status: String
	let uptime: Int
}
