import Vapor

enum Importance: String, Content {
	// Expense (negative) categories
	case essential // renamed: Groceries
	case leisure // renamed: Dining
	case investment // renamed: Auto + Transport
	case reward // renamed: Entertainment
	case occasional

	// Income (positive) categories
	case dayJob // renamed: Job
	case passiveIncome // renamed: Passive
	case oneTime
}
