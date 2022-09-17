//
//  PhotoMatchViewModel.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/09.
//

import Foundation
import SwiftUI

class PhotoMatchViewModel: ObservableObject {
    struct IdentifiableImage: Identifiable, Hashable {
        let id: Int
        let classNum: Int
        var image: UIImage
        var menuIndex: Int?
    }

    struct MealMenu: Identifiable, Hashable {
        let id: Int
        let menuData: Meal.MenuName
        var menuImage: UIImage?
    }

    static let classDict = [
        "bread",
        "food",
        "fruit",
        "noodle",
        "porridge",
        "processed",
        "rice",
        "rice_cake",
        "soup"
    ]

    @Published var croppedImageList = [IdentifiableImage]()
    @Published var selectedImageIndex: Int? {
        didSet {
            if let selectedImageIndex = selectedImageIndex {
                pickerSelection = croppedImageList[selectedImageIndex].menuIndex ?? -1
                pickerUpdate += 1
            } else {
                pickerSelection = -1
                pickerUpdate += 1
            }
        }
    }
    @Published var mealMenuList = [MealMenu]()
    @Published var pickerSelection = -1 {
        didSet {
            if let selectedImageIndex = selectedImageIndex {
                if croppedImageList[selectedImageIndex].menuIndex != pickerSelection &&
                   pickerSelection != -1 {
                    croppedImageList[selectedImageIndex].menuIndex = pickerSelection
                }
            }
        }
    }

    @Published var pickerUpdate = 0

    var mealid: Int?

    func refreshViewModel(sharedData: CameraTabView.SharedData, env: AppEnvironment) {
        self.cropImages(sharedData: sharedData)
        DispatchQueue.global(qos: .userInitiated).async {
            self.getMealInfo(env: env, sync: true)
            self.autoannotate()
            DispatchQueue.main.async {
                self.cropImages(sharedData: sharedData)
            }
        }
    }

    func autoannotate() {
        for (idx, cImage) in croppedImageList.enumerated() {
            for menu in mealMenuList where Self.classDict[cImage.classNum] == menu.menuData.menuname_classified {
                DispatchQueue.main.async {
                    self.croppedImageList[idx].menuIndex = menu.id
                }
            }
        }
    }

    func getMealInfo(env: AppEnvironment, sync: Bool = false) {
        let semaphore = DispatchSemaphore(value: 0)

        Meal.getMealInfo(schoolCode1: env.accountSession.userInfo.data!.schoolcode1,
                         schoolCode2: env.accountSession.userInfo.data!.schoolcode2,
                         action: .next) { result in
            switch result {
            case .success(let data):
                for (index, menu) in data.data!.menunames.enumerated() {
                    DispatchQueue.main.sync {
                        self.mealMenuList.append(MealMenu(id: index, menuData: menu))
                        self.pickerUpdate += 1
                    }
                }
                self.mealid = data.data!.mealid
            case .failure(let error):
                print(error.localizedDescription)
            }
            semaphore.signal()
        }

        if sync {
            semaphore.wait()
        }
    }

    func cropImages(sharedData: CameraTabView.SharedData) {
        let oldList = croppedImageList

        croppedImageList.removeAll()

        for data in sharedData.inferenceData {
            let rect = CGRect(x: data.xpos, y: data.ypos, width: data.width, height: data.height)
            let img = UIImage(cgImage: sharedData.originalImage.cgImage!.cropping(to: rect)!)

            var menuindex: Int?

            for cimage in oldList where cimage.id == data.id {
                menuindex = cimage.menuIndex
            }

            croppedImageList.append(IdentifiableImage(id: data.id,
                                                      classNum: data.class_num,
                                                      image: img,
                                                      menuIndex: menuindex ?? nil))
        }
    }

    func addInferenceData(sharedData: Binding<CameraTabView.SharedData>) {
        var id = 0
        for obj in sharedData.wrappedValue.inferenceData where obj.id == id {
            id += 1
        }

        let result = Inference.ResponseStruct(id: id,
                                            class_num: Inference.ClassEnum.food.rawValue,
                                            xpos: Int(sharedData.wrappedValue.originalImage.size.width) / 2 - 50,
                                            ypos: Int(sharedData.wrappedValue.originalImage.size.height) / 2 - 50,
                                            width: 100,
                                            height: 100)

        sharedData.wrappedValue.inferenceData.append(result)
    }

    func removeInfrerenceData(sharedData: Binding<CameraTabView.SharedData>, index: Int) {
        if sharedData.wrappedValue.inferenceData.count != 0 {
            if index >= 0 {
                sharedData.wrappedValue.inferenceData.remove(at: index)
                if sharedData.wrappedValue.inferenceData.count < 1 {
                    selectedImageIndex = -1
                } else {
                    selectedImageIndex = 0
                }
            }
        }
    }

    func getMenuId(infid: Int) -> Int? {
        for cImage in croppedImageList where cImage.id == infid {
            for menu in mealMenuList where menu.id == cImage.menuIndex {
                return menu.id
            }
        }

        return nil
    }

    func isValidResult() -> Bool {
        var menuIndexCount = Array(repeating: 0, count: mealMenuList.count)

        for cImage in croppedImageList {
            if let menuIndex = cImage.menuIndex {
                menuIndexCount[menuIndex] += 1
            } else {
                return false
            }

        }

        for idxCount in menuIndexCount where idxCount > 1 {
            return false
        }

        return true
    }

    func sendInferenceData(env: AppEnvironment, sharedData: CameraTabView.SharedData) {
        if !isValidResult() {
            env.addToast("응답을 확인한 후 다시 시도하세요.")
            return
        }

        let uploadData = sharedData.inferenceData.map({
            return Inference.UploadStruct(id: $0.id,
                                   class_num: $0.class_num,
                                   xpos: $0.xpos,
                                   ypos: $0.ypos,
                                   width: $0.width,
                                   height: $0.height,
                                   menuid: getMenuId(infid: $0.id)!)
        })

        Inference.uploadInference(mealid: mealid!, image: sharedData.originalImage,
                                  inferenceData: uploadData) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                        "changeView": ViewMessageExchanger.ViewEnum.homeTabView
                    ])
                    env.addToast("데이터가 전송되었습니다.")
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
