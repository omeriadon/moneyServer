import Vapor

struct HealthDTO: Content {
	let status: String
	let uptime: Int
}
