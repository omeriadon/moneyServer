import Vapor

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
