import Fluent
import struct Foundation.UUID
import Vapor

enum GoalStatus: String, Codable, CaseIterable {
	case active
	case paused
	case completed

	init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(String.self)
		let normalized = rawValue.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
		guard let status = GoalStatus(rawValue: normalized) else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Cannot initialize GoalStatus from invalid String value '\(rawValue)'"
			)
		}
		self = status
	}

	func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(rawValue)
	}
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

	@Field(key: "is_archived")
	var isArchived: Bool

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
		isArchived: Bool = false,
		userID: UUID
	) {
		self.id = id
		self.name = name
		self.description = description
		self.goalAmount = abs(goalAmount)
		self.status = status
		self.isArchived = isArchived
		$user.id = userID
	}
}
