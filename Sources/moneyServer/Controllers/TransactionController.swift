import Fluent
import Vapor

struct TransactionController: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		let transactions = routes.grouped("transactions")

		let tokenProtected = transactions.grouped(UserToken.authenticator(), User.guardMiddleware())
		tokenProtected.post(use: create)
		tokenProtected.get(use: list)
		tokenProtected.get(":transactionID", use: get)
		tokenProtected.delete(":transactionID", use: delete)
		tokenProtected.patch(":transactionID", use: update)
		tokenProtected.post("deleteMultiple", use: deleteMultiple)
	}

	func create(req: Request) async throws -> TransactionDTO {
		let dto = try req.content.decode(TransactionCreateDTO.self)
		let user = try req.auth.require(User.self)

		let transaction = Transaction(
			change: dto.change,
			title: dto.title,
			description: dto.description,
			importance: dto.importance,
			userID: user.id!
		)
		try await transaction.save(on: req.db)

		return TransactionDTO(
			id: transaction.id,
			change: transaction.change,
			title: transaction.title,
			description: transaction.description,
			importance: transaction.importance,
			userID: user.id!,
			dateCreated: transaction.dateCreated,
			dateUpdated: transaction.dateUpdated
		)
	}

	func list(req: Request) async throws -> [TransactionDTO] {
		let user = try req.auth.require(User.self)
		let transactions = try await Transaction.query(on: req.db)
			.filter(\.$user.$id == user.requireID())
			.all()

		return transactions.map { transaction in
			TransactionDTO(
				id: transaction.id,
				change: transaction.change,
				title: transaction.title,
				description: transaction.description,
				importance: transaction.importance,
				userID: user.id!,
				dateCreated: transaction.dateCreated,
				dateUpdated: transaction.dateUpdated
			)
		}
	}

	func get(req: Request) async throws -> TransactionDTO {
		let user = try req.auth.require(User.self)
		guard let id = req.parameters.get("transactionID", as: UUID.self),
		      let transaction = try await Transaction.query(on: req.db)
		      .filter(\.$id == id)
		      .filter(\.$user.$id == user.requireID())
		      .first()
		else {
			throw Abort(.notFound)
		}

		return TransactionDTO(
			id: transaction.id,
			change: transaction.change,
			title: transaction.title,
			description: transaction.description,
			importance: transaction.importance,
			userID: user.id!,
			dateCreated: transaction.dateCreated,
			dateUpdated: transaction.dateUpdated
		)
	}

	func update(req: Request) async throws -> TransactionDTO {
		let user = try req.auth.require(User.self)
		guard let id = req.parameters.get("transactionID", as: UUID.self),
		      let transaction = try await Transaction.query(on: req.db)
		      .filter(\.$id == id)
		      .filter(\.$user.$id == user.requireID())
		      .first()
		else {
			throw Abort(.notFound)
		}

		let update = try req.content.decode(TransactionUpdateDTO.self)

		if let change = update.change { transaction.change = change }
		if let title = update.title { transaction.title = title }
		if let description = update.description { transaction.description = description }
		if let importance = update.importance { transaction.importance = importance }

		try await transaction.save(on: req.db)

		return TransactionDTO(
			id: transaction.id,
			change: transaction.change,
			title: transaction.title,
			description: transaction.description,
			importance: transaction.importance,
			userID: user.id!,
			dateCreated: transaction.dateCreated,
			dateUpdated: transaction.dateUpdated
		)
	}

	func delete(req: Request) async throws -> HTTPStatus {
		let user = try req.auth.require(User.self)
		guard let transactionID = req.parameters.get("transactionID", as: UUID.self) else {
			throw Abort(.badRequest)
		}

		guard let transaction = try await Transaction.query(on: req.db)
			.filter(\.$id == transactionID)
			.filter(\.$user.$id == user.requireID())
			.first()
		else { throw Abort(.notFound) }

		try await transaction.delete(on: req.db)
		return .ok
	}

	func deleteMultiple(req: Request) async throws -> HTTPStatus {
		let user = try req.auth.require(User.self)
		let dto = try req.content.decode(TransactionDeleteDTO.self)

		try await Transaction.query(on: req.db)
			.filter(\.$id ~~ dto.ids)
			.filter(\.$user.$id == user.requireID())
			.delete()

		return .ok
	}
}
