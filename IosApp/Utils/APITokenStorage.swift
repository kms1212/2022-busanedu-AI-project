//
//  APITokenStorage.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/04.
//

import Foundation

class APITokenStorage {
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: "csrfToken") ?? nil
        }
        set(value) {
            UserDefaults.standard.set(value, forKey: "csrfToken")
        }
    }

    static var shared = APITokenStorage()
}
