//
//  MealComment.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/10.
//

import Foundation
import Alamofire

struct MealComment {
    struct ResponseStruct: Codable, Equatable {
        let commentid: Int
        let meal: Int
        let user: String
        let comment: String
    }

    var data: ResponseStruct?

    static func getMealComment(mealid: Int, _ completion: @escaping (_ result: Result<[Self], Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/comment", parameters: [
            "mealid": mealid
        ]).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<[Self], Error>?

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try Shared.jsonDecoder.decode([ResponseStruct].self, from: data)
                    result = .success(decoded.map({ MealComment(data: $0) }))
                } catch let error {
                    result = .failure(error)
                    print(error.localizedDescription)
                }

            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }.resume()
    }

    static func addMealComment(mealid: Int, comment: String,
                               _ completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/comment", method: .post, parameters: [
            "mealid": mealid,
            "comment": comment
        ], encoding: JSONEncoding.default).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<Void, Error>?

            switch response.result {
            case .success(let data):
                result = .success(())
            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }.resume()
    }
}
