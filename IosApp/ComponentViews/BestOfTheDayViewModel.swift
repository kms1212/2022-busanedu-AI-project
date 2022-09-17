//
//  BestOfTheDayViewModel.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/03.
//

import Foundation

class BestOfTheDayViewModel: ObservableObject {
    @Published var schoolData = LoadableValue<School>()
    @Published var mealData = LoadableValue<Meal>()

    func refreshMealData() {
        mealData = .loading

        Meal.getMealRanking(endidx: 1) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.mealData = .success(data[0])
                case .failure(let error):
                    self.mealData = .failure(error)
                    print(error.localizedDescription)
                }
             }
        }
    }

    func refreshSchoolData(schoolcode1: String, schoolcode2: String) {
        schoolData = .loading

        School.getSchoolInfoByCode(schoolCode1: schoolcode1,
                                   schoolCode2: schoolcode2) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.schoolData = .success(data)
                case .failure(let error):
                    self.schoolData = .failure(error)
                    print(error.localizedDescription)
                }
            }
        }
    }
}
