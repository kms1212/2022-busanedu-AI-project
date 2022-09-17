//
//  NearbySchoolViewModel.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/03.
//

import SwiftUI

class NearbySchoolViewModel: ObservableObject {
    struct Data {
        let school: School.ResponseStruct.SchoolDataStruct
        let meal: Meal
        let mealImage: UIImage?
    }

    @Published var nbsMealData = LoadableValue<[Data]>()
    @Published var nbsData = LoadableValue<[School.ResponseStruct.SchoolDataStruct]>()

    func refreshNbsData(schoolcode1: String, schoolcode2: String) {
        nbsData = .loading

        School.getNearbySchool(schoolCode1: schoolcode1,
                               schoolCode2: schoolcode2) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    var array = [School.ResponseStruct.SchoolDataStruct]()
                    for school in data.data!.data
                    where school.schoolcode1 != schoolcode1 || school.schoolcode2 != schoolcode2 {
                        array.append(school)
                    }
                    self.nbsData = .success(array)
                case .failure(let error):
                    self.nbsData = .failure(error)
                    print(error.localizedDescription)
                }
            }
        }
    }

    func refreshNbsMealData() {
        nbsMealData = .loading

        switch nbsData {
        case .success(let data):
            let mealtime = Meal.getCurrentMealTime(date: Date.now)
            let reqArray: [(Int, String, String, Date, Meal.MealTime)] = data.enumerated().map({
                return ($0, $1.schoolcode1, $1.schoolcode2, mealtime.0, mealtime.1)
            })

            Meal.getMealInfo(requestList: reqArray, action: .prev) { result2 in
                DispatchQueue.main.async {
                    switch result2 {
                    case .success(let mdata):
                        var result = [Data]()
                        for meal in mdata {
                            result.append(.init(school: data[meal.0], meal: meal.1, mealImage: nil))
                        }
                        self.nbsMealData = .success(result)
                    case .failure(let error):
                        self.nbsMealData = .failure(error)
                        print(error.localizedDescription)
                    }
                }
            }
        default:
            break
        }
    }
}
