//
//  MealDetailViewModel.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/10.
//

import Foundation

class MealDetailViewModel: ObservableObject {
    typealias AllergyData = [Int: Set<Int>] // [menuid: intersection(menuAllergyInfo, userAllergyInfo)]

    @Published var commentList = LoadableValue<[MealComment]>()
    @Published var inferenceList = LoadableValue<[MealInference]>()
    @Published var schoolInfo = LoadableValue<School>()
    @Published var mealData = LoadableValue<Meal>()
    @Published var allergyData = LoadableValue<AllergyData>()
    @Published var likeCount = LoadableValue<Int>()
    @Published var likeStatus = LoadableValue<Bool>()

    func addComment(comment: String) {
        switch mealData {
        case .success(let mealData):
            if let data = mealData.data {
                MealComment.addMealComment(mealid: data.mealid, comment: comment) { result in
                    switch result {
                    case .success:
                        self.refreshCommentList(mealid: data.mealid)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        default:
            break
        }
    }

    func autolike() {
        switch mealData {
        case .success(let mealData):
            if let data = mealData.data {
                MealLike.toggleLike(mealid: data.mealid) { result in
                    switch result {
                    case .success:
                        self.refreshLikeStatus(mealid: data.mealid)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        default:
            break
        }
    }

    func refreshCommentList(mealid: Int) {
        commentList = .loading

        MealComment.getMealComment(mealid: mealid) { result in
            DispatchQueue.main.async {
                self.commentList = .init(result)
            }

            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            default:
                break
            }
        }
    }

    func refreshInferenceList(mealid: Int) {
        inferenceList = .loading

        MealInference.getMealInference(mealid: mealid) { result in
            DispatchQueue.main.async {
                self.inferenceList = .init(result)
            }

            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            default:
                break
            }
        }
    }

    func refreshSchoolInfo(schoolcode1: String, schoolcode2: String) {
        schoolInfo = .loading

        School.getSchoolInfoByCode(schoolCode1: schoolcode1, schoolCode2: schoolcode2) { result in
            DispatchQueue.main.async {
                self.schoolInfo = .init(result)
            }

            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            default:
                break
            }
        }
    }

    func refreshMealDataAndAllergyData(mealid: Int, userAllergyInfo: [Int], sync: Bool = false) {
        mealData = .loading
        allergyData = .loading

        let semaphore = DispatchSemaphore(value: 0)
        var mealData: Result<Meal, Error>?
        var allergyData: Result<AllergyData, Error>?

        Meal.getMealInfo(mealid: mealid) { result in
            switch result {
            case .success(let mdata):
                if let data = mdata.data {
                    var tmp = AllergyData()
                    for menu in data.menunames {
                        let adat = Set(menu.menu_allergy_info).intersection(Set(userAllergyInfo))
                        if adat.count > 0 {
                            tmp[menu.menuid] = adat
                        }
                    }
                    allergyData = .success(tmp)
                } else {
                    allergyData = .failure(APIError.notExpectedValue)
                }
                mealData = .success(mdata)
            case .failure(let error):
                print(error.localizedDescription)
                mealData = .failure(error)
                allergyData = .failure(error)
            }

            if sync {
                semaphore.signal()
            } else {
                DispatchQueue.main.async {
                    self.mealData = .init(mealData!)
                    self.allergyData = .init(allergyData!)
                }
            }
        }

        if sync {
            semaphore.wait()

            self.mealData = .init(mealData!)
            self.allergyData = .init(allergyData!)
        }
    }

    func refreshLikeStatus(mealid: Int) {
        likeCount = .loading
        likeStatus = .loading

        MealLike.getLikeStatus(mealid: mealid) { result in
            DispatchQueue.main.async {
                self.likeStatus = .init(result)
            }

            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            default:
                break
            }
        }

        MealLike.getLikeCount(mealid: mealid) { result in
            DispatchQueue.main.async {
                self.likeCount = .init(result)
            }

            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            default:
                break
            }
        }
    }
}
