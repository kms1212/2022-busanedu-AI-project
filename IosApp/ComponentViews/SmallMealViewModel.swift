//
//  SmallMealViewModel.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/09.
//

import Foundation
import SwiftUI

class SmallMealViewModel: ObservableObject {
    @Published var schoolData = LoadableValue<School>()
    @Published var mealData = LoadableValue<Meal>()

    func refreshSchoolData(schoolcode1: String, schoolcode2: String) {
        schoolData = .loading
        School.getSchoolInfoByCode(schoolCode1: schoolcode1,
                                   schoolCode2: schoolcode2) { result in
            DispatchQueue.main.async {
                self.schoolData = .init(result)
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                default:
                    break
                }
            }
        }
    }

    func refreshMealData(schoolcode1: String, schoolcode2: String) {
        mealData = .loading
        Meal.getMealInfo(schoolCode1: schoolcode1,
                         schoolCode2: schoolcode2,
                         action: .next) { result in
            DispatchQueue.main.async {
                self.mealData = .init(result)
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                default:
                    break
                }
            }
        }
    }
}
