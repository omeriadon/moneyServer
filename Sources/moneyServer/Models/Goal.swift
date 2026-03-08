import Fluent
import struct Foundation.UUID
import Vapor

enum GoalStatus: String, Codable, CaseIterable {
	case active
	case paused
	case completed
	case archived
}

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

	@Field(key: "status")
	var status: GoalStatus

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
		status: GoalStatus = .active,
		userID: UUID
	) {
		self.id = id
		self.name = name
		self.description = description
		self.goalAmount = abs(goalAmount)
		self.status = status
		$user.id = userID
	}
}
