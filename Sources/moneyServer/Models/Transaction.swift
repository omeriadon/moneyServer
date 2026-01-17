import Fluent
import struct Foundation.UUID
import Vapor

final class Transaction: Model, @unchecked Sendable {
    static let schema = "transactions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "change")
    var change: Int

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(id: UUID? = nil, change: Int, userID: UUID) {
        self.id = id
        self.change = change
        $user.id = userID
    }
}
