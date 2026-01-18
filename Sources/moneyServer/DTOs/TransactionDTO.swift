import Vapor

struct TransactionDTO: Content {
	let id: UUID?
	let change: Int
	let userID: UUID

	init(id: UUID?, change: Int, userID: UUID) {
		self.id = id
		self.change = change
		self.userID = userID
	}
}
