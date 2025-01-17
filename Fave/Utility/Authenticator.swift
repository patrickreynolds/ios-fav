import Foundation
import SwiftKeychainWrapper

protocol Authenticateable {
    func login()
}

struct Authenticator {
    private let JWT_AUTHENTICATION_TOKEN_IDENTIFIER = "JWT_AUTHENTICATION_TOKEN_IDENTIFIER"

    let storage: StorageType

    init(storage: StorageType) {
        self.storage = storage
    }

    func token() -> String? {
        return KeychainWrapper.standard.string(forKey: JWT_AUTHENTICATION_TOKEN_IDENTIFIER)
    }

    func isLoggedIn() -> Bool {
        if storage.getUser() == nil {
            logout { success in

                print("\n\(success)\n")
            }

            return false
        }

        return hasJWTToken()
    }

    func hasJWTToken() -> Bool {
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

    func logout(completion: @escaping ((_ success: Bool) -> ())) {
        let success = KeychainWrapper.standard.removeObject(forKey: JWT_AUTHENTICATION_TOKEN_IDENTIFIER)

        storage.deleteUser()

        completion(success)
    }
}
