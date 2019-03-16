//
//  Authenticator.swift
//  Fave
//
//  Created by Patrick Reynolds on 3/14/19.
//  Copyright © 2019 Patrick Reynolds. All rights reserved.
//

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
        return KeychainWrapper.standard.string(forKey: JWT_AUTHENTICATION_TOKEN_IDENTIFIER)
    }

    func isLoggedIn() -> Bool {
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
