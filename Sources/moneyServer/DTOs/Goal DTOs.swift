import Vapor

struct GoalDTO: Content {
	let id: UUID?
	let name: String
	let description: String
	let goalAmount: Double
	let userID: UUID
	let dateCreated: Date?
	let dateUpdated: Date?
}

struct GoalCreateDTO: Content {
	let name: String
	let description: String
	let goalAmount: Double
}

struct GoalUpdateDTO: Content {
	let name: String?
	let description: String?
	let goalAmount: Double?
}

struct GoalDeleteDTO: Content {
	let ids: [UUID]
}
