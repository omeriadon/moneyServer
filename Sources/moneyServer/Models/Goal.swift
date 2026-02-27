import Fluent
import struct Foundation.UUID
import Vapor

final class Goal: Model, @unchecked Sendable {
	static let schema = "goals"

	@ID(key: .id)
	var id: UUID?

	@Field(key: "name")
	var name: String

	@Field(key: "description")
	var description: String

	@Field(key: "goal_amount")
	var goalAmount: Double

	@Parent(key: "user_id")
	var user: User

	@Timestamp(key: "date_created", on: .create)
	var dateCreated: Date?

	@Timestamp(key: "date_updated", on: .update)
	var dateUpdated: Date?

	init() {}

	init(
		id: UUID? = nil,
		name: String,
		description: String,
		goalAmount: Double,
		userID: UUID
	) {
		self.id = id
		self.name = name
		self.description = description
		self.goalAmount = abs(goalAmount)
		$user.id = userID
	}
}
