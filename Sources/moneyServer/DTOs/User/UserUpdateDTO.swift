import Vapor

struct UserUpdateDTO: Content {
	let firstName: String?
	let email: String?
	let password: String?
}
