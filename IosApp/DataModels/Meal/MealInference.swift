//
//  MealInference.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/10.
//

import Alamofire

struct MealInference {
    struct ResponseStruct: Codable, Equatable {
        let inferenceid: Int
        let meal: Int
        let user: String
        let mealimage: String
        let jsondata: String
    }

    struct ResultStruct: Equatable {
        let inferenceid: Int
        let meal: Int
        let user: String
        let mealimage: UIImage
        let jsondata: [Inference.UploadStruct]
    }

    var data: ResultStruct?

    static func responseToResult(resp: ResponseStruct) -> ResultStruct? {
        do {
            let decoded = try Shared.jsonDecoder.decode([Inference.UploadStruct].self,
                                                        from: resp.jsondata.data(using: .utf8)!)
            let image = downloadImageSync(url: URL(string: Constants.apiurl + resp.mealimage)!)!

            return ResultStruct(inferenceid: resp.inferenceid,
                                meal: resp.meal,
                                user: resp.user,
                                mealimage: image,
                                jsondata: decoded)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    static func getMealInference(mealid: Int, count: Int? = nil,
                                 _ completion: @escaping (_ result: Result<[Self], Error>) -> Void) {
        var parameters: Parameters = [
            "mealid": mealid
        ]

        if let count = count {
            parameters["count"] = count
        }

        APIRequestManager.session.request(Constants.apiurl + "meal/inference",
                                          parameters: parameters).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<[Self], Error>?

            switch response.result {
            case .success(let data):
                do {
                    print(String(data: data, encoding: .utf8)!)
                    let decoded = try Shared.jsonDecoder.decode([ResponseStruct].self, from: data)

                    result = .success(decoded.map({ MealInference(data: responseToResult(resp: $0)) }))
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
}
