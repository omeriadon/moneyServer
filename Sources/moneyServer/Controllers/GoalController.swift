import Fluent
import Vapor

struct GoalController: RouteCollection {
	func boot(routes: any RoutesBuilder) throws {
		let goals = routes.grouped("goals")

		let tokenProtected = goals.grouped(UserToken.authenticator(), User.guardMiddleware())
		tokenProtected.post(use: create)
		tokenProtected.get(use: list)
		tokenProtected.get(":goalID", use: get)
		tokenProtected.delete(":goalID", use: delete)
		tokenProtected.patch(":goalID", use: update)
		tokenProtected.post("deleteMultiple", use: deleteMultiple)
	}

	func create(req: Request) async throws -> GoalDTO {
		let dto = try req.content.decode(GoalCreateDTO.self)
		let user = try req.auth.require(User.self)

		let goal = Goal(
			name: dto.name,
			description: dto.description,
			goalAmount: abs(dto.goalAmount),
			status: dto.status ?? .active,
			userID: user.id!
		)
		try await goal.save(on: req.db)

		return GoalDTO(
			id: goal.id,
			name: goal.name,
			description: goal.description,
			goalAmount: goal.goalAmount,
			status: goal.status,
			userID: user.id!,
			dateCreated: goal.dateCreated,
			dateUpdated: goal.dateUpdated
		)
	}

	func list(req: Request) async throws -> [GoalDTO] {
		let user = try req.auth.require(User.self)
		let goals = try await Goal.query(on: req.db)
			.filter(\.$user.$id == user.requireID())
			.all()

		return goals.map { goal in
			GoalDTO(
				id: goal.id,
				name: goal.name,
				description: goal.description,
				goalAmount: goal.goalAmount,
				status: goal.status,
				userID: user.id!,
				dateCreated: goal.dateCreated,
				dateUpdated: goal.dateUpdated
			)
		}
	}

	func get(req: Request) async throws -> GoalDTO {
		let user = try req.auth.require(User.self)
		guard let id = req.parameters.get("goalID", as: UUID.self),
		      let goal = try await Goal.query(on: req.db)
		      .filter(\.$id == id)
		      .filter(\.$user.$id == user.requireID())
		      .first()
		else {
			throw Abort(.notFound)
		}

		return GoalDTO(
			id: goal.id,
			name: goal.name,
			description: goal.description,
			goalAmount: goal.goalAmount,
			status: goal.status,
			userID: user.id!,
			dateCreated: goal.dateCreated,
			dateUpdated: goal.dateUpdated
		)
	}

	func update(req: Request) async throws -> GoalDTO {
		let user = try req.auth.require(User.self)
		guard let id = req.parameters.get("goalID", as: UUID.self),
		      let goal = try await Goal.query(on: req.db)
		      .filter(\.$id == id)
		      .filter(\.$user.$id == user.requireID())
		      .first()
		else {
			throw Abort(.notFound)
		}

		let update = try req.content.decode(GoalUpdateDTO.self)

		if let name = update.name { goal.name = name }
		if let description = update.description { goal.description = description }
		if let goalAmount = update.goalAmount { goal.goalAmount = abs(goalAmount) }
		if let status = update.status { goal.status = status }

		try await goal.save(on: req.db)

		guard let refreshed = try await Goal.find(goal.id, on: req.db) else {
			throw Abort(.internalServerError, reason: "Couldn't find item after updating")
		}

		return GoalDTO(
			id: refreshed.id,
			name: refreshed.name,
			description: refreshed.description,
			goalAmount: refreshed.goalAmount,
			status: refreshed.status,
			userID: user.id!,
			dateCreated: refreshed.dateCreated,
			dateUpdated: refreshed.dateUpdated
		)
	}

	func delete(req: Request) async throws -> HTTPStatus {
		let user = try req.auth.require(User.self)
		guard let goalID = req.parameters.get("goalID", as: UUID.self) else {
			throw Abort(.badRequest)
		}

		guard let goal = try await Goal.query(on: req.db)
			.filter(\.$id == goalID)
			.filter(\.$user.$id == user.requireID())
			.first()
		else { throw Abort(.notFound) }

		try await goal.delete(on: req.db)
		return .ok
	}

	func deleteMultiple(req: Request) async throws -> HTTPStatus {
		let user = try req.auth.require(User.self)
		let dto = try req.content.decode(GoalDeleteDTO.self)

		try await Goal.query(on: req.db)
			.filter(\.$id ~~ dto.ids)
			.filter(\.$user.$id == user.requireID())
			.delete()

		return .ok
	}
}
