import Vapor

enum Importance: String, Content {
	case essential, leisure, investment, reward, emergency, occasional

	case dayJob, passiveIncome, oneTime
}
