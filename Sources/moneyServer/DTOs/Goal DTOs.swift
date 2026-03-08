import Vapor

struct GoalDTO: Content {
	let id: UUID?
	let name: String
	let description: String
	let goalAmount: Double
	let status: GoalStatus
	let userID: UUID
	let dateCreated: Date?
	let dateUpdated: Date?
}

struct GoalCreateDTO: Content {
	let name: String
	let description: String
	let goalAmount: Double
	let status: GoalStatus?
}

struct GoalUpdateDTO: Content {
	let name: String?
	let description: String?
	let goalAmount: Double?
	let status: GoalStatus?
}

struct GoalDeleteDTO: Content {
	let ids: [UUID]
}
