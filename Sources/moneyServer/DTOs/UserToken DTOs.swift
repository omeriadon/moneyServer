import Vapor

struct UserTokenResponseDTO: Content {
	let token: String
	let user: UserDTO
}
