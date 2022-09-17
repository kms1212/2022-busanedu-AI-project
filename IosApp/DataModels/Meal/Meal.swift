//
//  Meal.swift
//  IosApp
//
//  Created by 권민수 on 2022/08/30.
//

import Foundation
import Alamofire

struct Meal {
// swiftlint:disable identifier_name
    struct ResponseStruct: Codable, Equatable {
        let mealid: Int
        let schoolcode1: String
        let schoolcode2: String
        let mealdate: String
        let mealtime: Int
        let likecnt: Int
        let menunames: [MenuName]
    }

    struct MenuName: Codable, Equatable, Hashable {
        let menuid: Int
        let menuname: String
        let menuname_filtered: String
        let menuname_classified: String
        let menu_allergy_info: [Int]
    }

    struct BatchDataResponseStruct: Codable, Equatable {
        let reqid: Int
        let data: ResponseStruct
    }

    enum MealTime: Int {
        case none = 0, breakfast = 1, lunch = 2, dinner = 3
    }

    enum BatchAction: String {
        case code, next, prev
    }

    enum Action: String {
        case next, prev
    }
// swiftlint:enable identifier_name

    static let mealTimeDict = [
        "",
        "조식",
        "중식",
        "석식"
    ]

    var data: ResponseStruct?

    static internal func respToMeal(respArr: [ResponseStruct]) throws -> [Meal] {
        return respArr.map({
            Meal(data: $0)
        })
    }

    static internal func getCurrentMealTime(date: Date) -> (Date, MealTime) {
        let curhour = Calendar.current.component(.hour, from: date)

        var date = date
        var result: MealTime

        if curhour < 9 {
            result = .breakfast
        } else if curhour < 14 {
            result = .lunch
        } else if curhour > 19 {
            date = date.dayAfter
            result = .breakfast
        } else {
            result = .dinner
        }
        return (date, result)
    }

    static func getMealRanking(startidx: Int = 0, endidx: Int = 10,
                               _ completion: @escaping (_ result: Result<[Self], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        dateFormatter.timeZone = .current

        APIRequestManager.session.request(Constants.apiurl + "meal/ranking",
                   parameters: [
                    "start": startidx,
                    "end": endidx
                   ]).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<[Self], Error>?

            switch response.result {
            case .success(let data):
                do {
                    var decoded = try Shared.jsonDecoder.decode([ResponseStruct].self, from: data)
                    decoded = decoded.sorted { return $0.likecnt > $1.likecnt }
                    result = .success(try respToMeal(respArr: decoded))
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

    static func getMealInfo(schoolCode1: String, schoolCode2: String,
                            date: Date, time: MealTime?,
                            _ completion: @escaping (_ result: Result<[Self], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        dateFormatter.timeZone = .current

        var parameters = [
            "schoolcode1": schoolCode1,
            "schoolcode2": schoolCode2,
            "mealdate": dateFormatter.string(from: date)]

        if let time = time {
            parameters["mealtime"] = String(time.rawValue)
        }

        APIRequestManager.session.request(Constants.apiurl + "meal/data", parameters: parameters).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<[Self], Error>?

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try Shared.jsonDecoder.decode([ResponseStruct].self, from: data)
                    result = .success(try respToMeal(respArr: decoded))
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

    static func getMealInfo(mealid: Int, _ completion: @escaping (_ result: Result<Self, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/data",
                                          parameters: [
                                            "action": "id",
                                            "mealid": mealid
                                          ]).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<Self, Error>?

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try Shared.jsonDecoder.decode(ResponseStruct.self, from: data)
                    result = .success(try respToMeal(respArr: [decoded])[0])
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

    static func getMealInfo(schoolCode1: String, schoolCode2: String, action: Action,
                            _ completion: @escaping (_ result: Result<Self, Error>) -> Void) {
        var date: Date
        var mealTime: MealTime
        (date, mealTime) = getCurrentMealTime(date: Date.now)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        dateFormatter.timeZone = .current

        var datestring = UserDefaults.standard.string(forKey: "date_override")

        if datestring == nil {
            datestring = dateFormatter.string(from: date)
        }

        APIRequestManager.session.request(Constants.apiurl + "meal/data",
                   parameters: [
                    "action": action.rawValue,
                    "schoolcode1": schoolCode1,
                    "schoolcode2": schoolCode2,
                    "mealdate": datestring!,
                    "mealtime": String(mealTime.rawValue)]).validate()
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<Self, Error>?

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try Shared.jsonDecoder.decode([ResponseStruct].self, from: data)
                    result = .success(try respToMeal(respArr: decoded)[0])
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

// swiftlint:disable large_tuple
    static func getMealInfo(requestList: [(Int, String, String, Date, MealTime)], action: BatchAction,
                            _ completion: @escaping (_ result: Result<[(Int, Self)], Error>) -> Void) {
// swiftlint:enable large_tuple
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        dateFormatter.timeZone = .current

        var list = [Parameters]()
        for reqData in requestList {
            list.append([
                "reqid": reqData.0,
                "schoolcode1": reqData.1,
                "schoolcode2": reqData.2,
                "mealdate": dateFormatter.string(from: reqData.3),
                "mealtime": reqData.4.rawValue
            ])
        }

        let parameters: Parameters = [
            "action": action.rawValue,
            "codelist": list
        ]

        APIRequestManager.session.request(Constants.apiurl + "meal/data", method: .post,
                                          parameters: parameters, encoding: JSONEncoding.default)
            .validate().responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<[(Int, Self)], Error>?

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try Shared.jsonDecoder.decode([BatchDataResponseStruct].self, from: data)
                    var array = [(Int, Self)]()
                    for meal in decoded {
                        array.append((meal.reqid, try respToMeal(respArr: [meal.data])[0]))
                    }
                    result = .success(array)
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

    static func getMealInfo(requestList: [(Int, Int)],
                            _ completion: @escaping (_ result: Result<[(Int, Self)], Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        dateFormatter.timeZone = .current

        var list = [Parameters]()
        for reqData in requestList {
            list.append([
                "reqid": reqData.0,
                "mealid": reqData.1
            ])
        }

        let parameters: Parameters = [
            "action": "id",
            "codelist": list
        ]

        APIRequestManager.session.request(Constants.apiurl + "meal/data", method: .post,
                                          parameters: parameters, encoding: JSONEncoding.default)
            .validate().responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<[(Int, Self)], Error>?

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try Shared.jsonDecoder.decode([BatchDataResponseStruct].self, from: data)
                    var array = [(Int, Self)]()
                    for meal in decoded {
                        array.append((meal.reqid, try respToMeal(respArr: [meal.data])[0]))
                    }
                    result = .success(array)
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

    static func getRandomMeal(schoolcode1: String, schoolcode2: String,
                                       _ completion: @escaping (_ result: Result<[Self], Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/randmeal",
                                          parameters: [
            "schoolcode1": schoolcode1,
            "schoolcode2": schoolcode2
        ]).validate()
            .responseData(queue: .global(qos: .userInitiated)) { response in
            var result: Result<[Self], Error>?

            switch response.result {
            case .success(let data):
                do {
                    print(String(data: data, encoding: .utf8)!)
                    let decoded = try Shared.jsonDecoder.decode([ResponseStruct].self, from: data)

                    result = .success(try Meal.respToMeal(respArr: decoded).shuffled())
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
