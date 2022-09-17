//
//  School.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/06.
//

import Foundation
import Alamofire
import SwiftUI

struct School: Equatable {
// swiftlint:disable identifier_name
    struct ResponseStruct: Codable, Equatable {
        struct SchoolDataStruct: Identifiable, Codable, Equatable {
            let id: Int
            let schoolcode1: String
            let schoolcode2: String
            let school_name: String
            let school_grade: String
            let location: String
            let found_type: String
            let school_addr: String
            let coedu: String
            let school_type: String
            let latitude: String
            let longitude: String
        }

        let count: Int
        let data: [SchoolDataStruct]
    }

    struct BatchDataResponseStruct: Codable, Equatable {
        let reqid: Int
        let data: ResponseStruct.SchoolDataStruct
    }
// swiftlint:enable identifier_name

    var data: ResponseStruct?

    static func getSchoolInfoByName(schoolName: String, page: Int, pageSize: Int,
                                    _ completion: @escaping (_ result: Result<Self, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/school",
                   parameters: [
                    "action": "search",
                    "keyword": schoolName,
                    "page": page,
                    "pagesz": pageSize]).validate().responseData { response in
            var result: Result<Self, Error>?

            switch response.result {
            case .success(let response):
                do {
                    result = .success(Self(data: try Shared.jsonDecoder.decode(ResponseStruct.self, from: response)))
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

    static func getSchoolInfoByCode(schoolCode1: String, schoolCode2: String,
                                    _ completion: @escaping (_ result: Result<Self, Error>) -> Void) {
        APIRequestManager.session.request(Constants.apiurl + "meal/school",
                   parameters: [
                    "schoolcode1": schoolCode1,
                    "schoolcode2": schoolCode2]).validate()
            .responseData(queue: .global(qos: .userInitiated)) { response in
            var result: Result<Self, Error>?

            switch response.result {
            case .success(let response):
                do {
                    let tmp = try Shared.jsonDecoder.decode(ResponseStruct.SchoolDataStruct.self, from: response)
                    result = .success(Self(data: ResponseStruct(count: 1, data: [tmp])))
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

    static func getNearbySchool(schoolCode1: String, schoolCode2: String,
                                _ completion: @escaping (_ result: Result<Self, Error>) -> Void) {
        getSchoolInfoByCode(schoolCode1: schoolCode1, schoolCode2: schoolCode2) { result1 in
            var result: Result<Self, Error>?

            switch result1 {
            case .success(let data):
                let semaphore = DispatchSemaphore(value: 0)

                APIRequestManager.session.request(Constants.apiurl + "meal/school",
                           parameters: [
                            "action": "nearby",
                            "latitude": data.data!.data[0].latitude,
                            "longitude": data.data!.data[0].longitude]).validate()
                    .responseData(queue: .global(qos: .userInitiated)) { result2 in
                    switch result2.result {
                    case .success(let response):
                        do {
                            result = .success(Self(data: try Shared.jsonDecoder.decode(ResponseStruct.self,
                                                                                       from: response)))
                        } catch let error {
                            result = .failure(error)
                            print(error.localizedDescription)
                        }

                    case .failure(let error):
                        result = .failure(error)
                        print(error.localizedDescription)
                    }
                    semaphore.signal()
                }.resume()
                semaphore.wait()
            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }
    }

// swiftlint:disable large_tuple
    static func getBatchSchoolInfo(requestList: [(Int, String, String)],
                                   _ completion: @escaping (_ result: Result<[(Int, Self)], Error>) -> Void) {
// swiftlint:enable large_tuple
        var list = [Parameters]()
        for reqData in requestList {
            list.append([
                "reqid": reqData.0,
                "schoolcode1": reqData.1,
                "schoolcode2": reqData.2
            ])
        }

        let parameters: Parameters = [
            "action": "code",
            "codelist": list
        ]

        APIRequestManager.session.request(Constants.apiurl + "meal/school", method: .post,
                                          parameters: parameters, encoding: JSONEncoding.default)
            .validate().responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
            var result: Result<[(Int, Self)], Error>?

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try Shared.jsonDecoder.decode([BatchDataResponseStruct].self, from: data)
                    var array = [(Int, Self)]()
                    for school in decoded {
                        array.append((school.reqid, Self(data: ResponseStruct(count: 1, data: [school.data]))))
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

    static func == (lhs: School, rhs: School) -> Bool {
        return lhs.data == rhs.data
    }
}
