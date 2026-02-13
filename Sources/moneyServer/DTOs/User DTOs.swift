import Vapor

struct UserDTO: Content {
	let id: UUID?
	let firstName: String
	let email: String
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

struct UserLoginDTO: Content {
	let email: String
	let password: String
}
