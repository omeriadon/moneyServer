import Vapor

struct TransactionCreateDTO: Content {
	let change: Int
}
