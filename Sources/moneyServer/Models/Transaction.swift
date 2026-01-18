import Fluent
import struct Foundation.UUID
import Vapor

final class Transaction: Model, @unchecked Sendable {
	static let schema = "transactions"

	@ID(key: .id)
	var id: UUID?

	@Field(key: "change")
	var change: Int

	@Field(key: "title")
	var title: String

	@Field(key: "description")
	var description: String

	@Field(key: "importance")
	var importance: Importance

	@Parent(key: "user_id")
	var user: User

	@Timestamp(key: "date_created", on: .create)
	var dateCreated: Date?

	@Timestamp(key: "date_updated", on: .update)
	var dateUpdated: Date?

	init() {}

	init(
		id: UUID? = nil,
		change: Int,
		title: String,
		description: String,
		importance: Importance,
		userID: UUID
	) {
		self.id = id
		self.change = change
		self.title = title
		self.description = description
		self.importance = importance
		$user.id = userID
	}
}

extension Transaction {
	var positive: Bool {
		change > 0
	}
}
