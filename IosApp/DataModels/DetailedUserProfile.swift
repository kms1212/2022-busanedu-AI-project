//
//  DetailedUseerProfile.swift
//  iosApp
//
//  Created by 권민수 on 2022/06/05.
//

import Foundation
import Alamofire
import SwiftUI

struct DetailedUserProfile {
    struct DetailedResponseStruct: Codable, Equatable {
        let userid: String
        let username: String
        let email: String
        let description: String?
        let profileimage: String?
        let usertype: Int
        let firstname: String
        let lastname: String
        let birthdate: String
        let schoolcode1: String
        let schoolcode2: String
        let schoolgrade: Int
        let schoolclass: Int
        let schoolpid: Int
        let allergyinfo: [Int]
    }

    var data: DetailedResponseStruct?
    var profileImage: UIImage?

    static func getProfile(_ completion: @escaping (_ result: Result<Self, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "auth/profile").validate()
            .responseData(queue: .global(qos: .userInitiated)) { response in
            var result: Result<Self, Error>?

            do {
                switch response.result {
                case .success(let response):
                    let data = try Shared.jsonDecoder.decode(DetailedResponseStruct.self, from: response)

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

                case .failure(let error):
                    result = .failure(error)
                    print(error.localizedDescription)
                }
            } catch let error {
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }.resume()
    }
}
