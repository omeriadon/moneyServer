import Vapor

struct UserDTO: Content {
	let id: UUID?
	let firstName: String
	let email: String

	init(id: UUID?, firstName: String, email: String) {
		self.id = id
		self.firstName = firstName
		self.email = email
	}
}
