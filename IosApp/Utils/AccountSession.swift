//
//  AccountSession.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/08.
//

import Foundation
import Alamofire
import SwiftUI
import Combine

class AccountSession: ObservableObject {
    struct RequestStruct {
        var username: String
        var password: String
    }

    @Published var userInfo = DetailedUserProfile()
    @Published var schoolInfo = School()

    func getSchoolData() {
        School.getSchoolInfoByCode(schoolCode1: userInfo.data!.schoolcode1,
                                   schoolCode2: userInfo.data!.schoolcode2) { result in
            switch result {
            case .success(let data):
                self.schoolInfo = data
            case .failure(let error):
                self.schoolInfo = School()
                print(error.localizedDescription)
            }
        }
    }

    func login(username: String, password: String, _ action: @escaping (Result<DetailedUserProfile, Error>) -> Void) {
        let semaphore = DispatchSemaphore(value: 0)

        APIRequestManager.session.request(Constants.apiurl + "auth/login/", method: .post, parameters: [
            "username": username,
            "password": password
        ]).validate().response(queue: .global(qos: .userInitiated)) { _ in
            semaphore.signal()
        }.resume()

        semaphore.wait()
        DetailedUserProfile.getProfile { result in
            switch result {
            case .success(let data):
                self.userInfo = data

                let semaphore = DispatchSemaphore(value: 0)

                APIAuthInterceptor.getCsrfToken { _ in
                    semaphore.signal()
                }
                semaphore.wait()

                action(.success(data))
            case .failure(let error):
                print(error.localizedDescription)
                action(.failure(error))
            }
        }
    }

    func tryLoginWithCookie() {
        let semaphore = DispatchSemaphore(value: 0)

        DetailedUserProfile.getProfile { result in
            switch result {
            case .success(let data):
                self.userInfo = data
            case .failure(let error):
                print(error.localizedDescription)
                self.userInfo.data = nil
                self.userInfo.profileImage = nil
            }
            semaphore.signal()
        }
        semaphore.wait()
    }

    func logout() {
        let semaphore = DispatchSemaphore(value: 0)

        AF.request(Constants.apiurl + "auth/logout/").validate().response(queue: .global(qos: .userInitiated)) { _ in
            semaphore.signal()
        }.resume()
        semaphore.wait()
    }
}
