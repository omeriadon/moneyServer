import Fluent
import Vapor

struct TransactionController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let transactions = routes.grouped("transactions")
        transactions.post(use: create)
        transactions.get(use: list)
        transactions.get(":transactionID", use: get)
    }

    func create(req: Request) async throws -> TransactionDTO {
        let dto = try req.content.decode(TransactionDTO.self)
        let transaction = Transaction(change: dto.change, userID: dto.userID)
        try await transaction.save(on: req.db)
        return TransactionDTO(id: transaction.id, change: transaction.change, userID: dto.userID)
    }

    func list(req: Request) async throws -> [TransactionDTO] {
        let transactions = try await Transaction.query(on: req.db).all()
        return transactions.map { TransactionDTO(id: $0.id, change: $0.change, userID: $0.$user.id) }
    }

    func get(req: Request) async throws -> TransactionDTO {
        guard let id = req.parameters.get("transactionID", as: UUID.self),
              let transaction = try await Transaction.find(id, on: req.db)
        else { throw Abort(.notFound) }
        return TransactionDTO(id: transaction.id, change: transaction.change, userID: transaction.$user.id)
    }
}
