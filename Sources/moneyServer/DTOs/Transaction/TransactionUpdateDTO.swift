import Vapor

struct TransactionUpdateDTO: Content {
	let change: Int?
}
