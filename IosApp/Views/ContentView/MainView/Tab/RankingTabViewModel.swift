//
//  RankingTabViewModel.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/09.
//

import Foundation

class RankingTabViewModel: ObservableObject {
    struct RankingDataStruct {
        var schoolData: School
        var mealData: Meal
    }

    @Published var mealRanking = LoadableValue<[RankingDataStruct]>()
    @Published var rawMealRanking = LoadableValue<[Meal]>()
    @Published var detailViewIndex = -1
    @Published var page = 0

    func refreshRawMealRanking() {
        rawMealRanking = .loading

        Meal.getMealRanking(startidx: page * 30, endidx: page * 30 + 30) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    var tmp = [Meal]()
                    for meal in data {
                        tmp.append(meal)
                    }
                    self.rawMealRanking = .success(tmp)
                case .failure(let error):
                    self.rawMealRanking = .failure(error)
                    print(error.localizedDescription)
                }
            }
        }
    }

    func refreshMealRanking() {
        mealRanking = .loading

        switch rawMealRanking {
        case .success(let rawMealRanking):
            let reqList = rawMealRanking.enumerated().map({ return ($0,
                                                                    $1.data!.schoolcode1,
                                                                    $1.data!.schoolcode2) })

            School.getBatchSchoolInfo(requestList: reqList) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        var tmp = [RankingDataStruct]()
                        for meal in data {
                            tmp.append(.init(schoolData: meal.1, mealData: rawMealRanking[meal.0]))
                        }
                        self.mealRanking = .success(tmp)
                    case .failure(let error):
                        self.mealRanking = .failure(error)
                        print(error.localizedDescription)
                    }
                }
            }
        default:
            mealRanking = .waiting
        }
    }
}
