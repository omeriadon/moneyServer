import Vapor

struct TransactionDeleteDTO: Content {
	let ids: [UUID]
}
