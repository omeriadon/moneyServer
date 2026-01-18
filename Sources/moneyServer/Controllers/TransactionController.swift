import Fluent
import Vapor

struct TransactionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let transactions = routes.grouped("transactions")

        let tokenProtected = transactions.grouped(UserToken.authenticator(), User.guardMiddleware())
        tokenProtected.post(use: create)
        tokenProtected.get(use: list)
        tokenProtected.get(":transactionID", use: get)
    }

    func create(req: Request) async throws -> TransactionDTO {
        let dto = try req.content.decode(TransactionCreateDTO.self)
        let user = try req.auth.require(User.self)

        let transaction = try Transaction(change: dto.change, userID: user.requireID())
        try await transaction.save(on: req.db)
        return TransactionDTO(id: transaction.id, change: transaction.change, userID: user.id!)
    }

    func list(req: Request) async throws -> [TransactionDTO] {
        let user = try req.auth.require(User.self)
        let transactions = try await Transaction.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .all()

        return transactions.map { TransactionDTO(id: $0.id, change: $0.change, userID: user.id!) }
    }

    func get(req: Request) async throws -> TransactionDTO {
        let user = try req.auth.require(User.self)
        guard let id = req.parameters.get("transactionID", as: UUID.self),
              let transaction = try await Transaction.query(on: req.db)
              .filter(\.$id == id)
              .filter(\.$user.$id == user.id!)
              .first()
        else { throw Abort(.notFound) }

        return TransactionDTO(id: transaction.id, change: transaction.change, userID: user.id!)
    }
}
