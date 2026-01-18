import Vapor

struct TransactionDTO: Content {
	let id: UUID?
	let change: Int
	let title: String
	let description: String
	let importance: Importance
	let userID: UUID
	let dateCreated: Date?
	let dateUpdated: Date?
}

struct TransactionCreateDTO: Content {
	let change: Int
	let title: String
	let description: String
	let importance: Importance
}

struct TransactionUpdateDTO: Content {
	let change: Int?
	let title: String?
	let description: String?
	let importance: Importance?
}

struct TransactionDeleteDTO: Content {
	let ids: [UUID]
}
