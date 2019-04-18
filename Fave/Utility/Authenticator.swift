import Foundation
import SwiftKeychainWrapper

protocol Authenticateable {
    func login()
}

/*
var loggedIn: Bool = false
var accessToken: String?

//        FBSDKLoginManager().logOut()

if FBSDKAccessToken.current() != nil {
    if let latestAccessToken = FBSDKAccessToken.current(),
        let latestTokenString = latestAccessToken.tokenString {
        loggedIn = true
        accessToken = latestTokenString
    }
}
 */

struct Authenticator {
    private let JWT_AUTHENTICATION_TOKEN_IDENTIFIER = "JWT_AUTHENTICATION_TOKEN_IDENTIFIER"

    func token() -> String? {
//        user1 return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjEsImlhdCI6MTU1NDIxMDMxNiwiZXhwIjo0Njk5MTcwMzE2fQ.aQRXkj8bkFidaPj_ThLhvj3whyDhjQuU9YGgW9MhoBg"
//        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjIsImlhdCI6MTU1NDIxMDQ4OCwiZXhwIjo0Njk5MTcwNDg4fQ.xXzGP3sZf7zWonrioUN1A6EQ6buYGIVbOVZGlyeOVAU"
        return KeychainWrapper.standard.string(forKey: JWT_AUTHENTICATION_TOKEN_IDENTIFIER)
    }

    func isLoggedIn() -> Bool {
//        return true

        if let _ = KeychainWrapper.standard.string(forKey: JWT_AUTHENTICATION_TOKEN_IDENTIFIER) {
            return true
        } else {
            return false
        }
    }

    func login(jwtToken: String, completion: @escaping (_ success: Bool) -> ()) {
        let success = KeychainWrapper.standard.set(jwtToken, forKey: JWT_AUTHENTICATION_TOKEN_IDENTIFIER)

        completion(success)
    }

    func logout(completion: @escaping (_ success: Bool) -> ()) {
        let success = KeychainWrapper.standard.removeObject(forKey: JWT_AUTHENTICATION_TOKEN_IDENTIFIER)

        completion(success)
    }
}
