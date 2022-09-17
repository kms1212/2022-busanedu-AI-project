//
//  MealLike.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/10.
//

import Foundation
import Alamofire

struct MealLike {
    struct RequestStruct: Codable, Equatable {
        let mealid: Int
    }

    static func getLikeCount(mealid: Int, _ completion: @escaping (_ result: Result<Int, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/like", parameters: [
            "action": "count",
            "mealid": mealid
        ]).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<Int, Error>?

            switch response.result {
            case .success(let data):
                result = .success(Int(String(data: data, encoding: .utf8)!)!)
            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }.resume()
    }

    static func getLikeStatus(mealid: Int, _ completion: @escaping (_ result: Result<Bool, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/like", parameters: [
            "action": "stat",
            "mealid": mealid
        ]).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<Bool, Error>?

            switch response.result {
            case .success(let data):
                result = .success(Int(String(data: data, encoding: .utf8)!)! == 1)

            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }.resume()
    }

    static func toggleLike(mealid: Int, _ completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/like", method: .post, parameters: [
            "mealid": mealid
        ], encoding: JSONEncoding.default).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<Void, Error>?

            switch response.result {
            case .success:
                result = .success(())
            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }.resume()
    }
}
