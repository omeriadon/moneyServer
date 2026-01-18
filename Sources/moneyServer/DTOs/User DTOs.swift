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

struct UserCreateDTO: Content, Validatable {
	let firstName: String
	let email: String
	let password: String

	static func validations(_ validations: inout Validations) {
		validations.add("firstName", as: String.self, is: !.empty)
		validations.add("email", as: String.self, is: .email)
		validations.add("password", as: String.self, is: .count(8...))
	}
}

struct UserUpdateDTO: Content {
	let firstName: String?
	let email: String?
	let password: String?
}
