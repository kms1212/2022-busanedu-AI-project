//
//  UserProfile.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/10.
//

import Foundation
import Alamofire
import SwiftUI

struct UserProfile {
    struct ResponseStruct: Codable {
        let userid: String
        let username: String
        let description: String?
        let profileimage: String?
    }

    var data: ResponseStruct?
    var profileImage: UIImage?

    static func getProfile(userid: String, _ completion: @escaping (_ result: Result<Self, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "auth/profile",
                   parameters: ["userid": userid]).validate()
            .responseData(queue: .global(qos: .userInitiated)) { response in
            var result: Result<Self, Error>?

            switch response.result {
            case .success(let response):
                do {
                    let data = try Shared.jsonDecoder.decode(ResponseStruct.self, from: response)

                    if let imageUrl = data.profileimage {
                        let semaphore = DispatchSemaphore(value: 0)

                        downloadImageAsync(url: URL(string: Constants.apiurl.dropLast() + imageUrl)!) { image in
                            result = .success(Self(data: data, profileImage: image))
                            semaphore.signal()
                        }
                        semaphore.wait()
                    } else {
                        result = .success(Self(data: data))
                    }
                } catch let error {
                    print(error.localizedDescription)
                    result = .failure(error)
                }
            case .failure(let error):
                print(error.localizedDescription)
                result = .failure(error)
            }

            completion(result!)
        }.resume()
    }
}
