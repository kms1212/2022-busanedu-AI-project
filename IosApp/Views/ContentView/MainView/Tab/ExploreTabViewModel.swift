//
//  ExploreTabViewModel.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/09.
//

import Foundation

class ExploreTabViewModel: ObservableObject {
    struct Data {
        var mealInfo: Meal.ResponseStruct
        var schoolInfo: School.ResponseStruct.SchoolDataStruct
        var inferenceImage: UIImage
    }

    @Published var gridData = LoadableValue<[Data]>()

    func refreshGridData(schoolcode1: String, schoolcode2: String) {
        gridData = .loading

        Meal.getRandomMeal(schoolcode1: schoolcode1,
                           schoolcode2: schoolcode2) { response in
            var result: Result<[Data], Error>?

            switch response {
            case .success(let mdata):
                let semaphore = DispatchSemaphore(value: 0)
                var tmp = [Data]()
                var reqlist = [(Int, String, String)]()

                reqlist = mdata.enumerated().map({($0, $1.data!.schoolcode1, $1.data!.schoolcode2)})

                School.getBatchSchoolInfo(requestList: reqlist) { response2 in
                    switch response2 {
                    case .success(let sdata):
                        for school in sdata {
                            let semaphore2 = DispatchSemaphore(value: 0)

                            MealInference.getMealInference(mealid: mdata[school.0].data!.mealid,
                                                           count: 1) { response3 in
                                switch response3 {
                                case .success(let idata):
                                    tmp.append(Data(mealInfo: mdata[school.0].data!,
                                                     schoolInfo: school.1.data!.data[0],
                                                     inferenceImage: idata[0].data!.mealimage))
                                case .failure(let error):
                                    print(error.localizedDescription)
                                }
                                semaphore2.signal()
                            }
                            semaphore2.wait()
                        }

                        if tmp.count != 0 {
                            result = .success(tmp)
                        }
                    case .failure(let error):
                        print(error.localizedDescription)
                    }

                    semaphore.signal()
                }
                semaphore.wait()
            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            DispatchQueue.main.async {
                if result == nil {
                    self.gridData = .failure(APIError.notExpectedValue)
                } else {
                    self.gridData = .init(result!)
                }
            }
        }
    }
}
