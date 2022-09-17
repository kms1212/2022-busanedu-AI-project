//
//  InferenceRequestViewModel.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/09.
//

import Foundation
import SwiftUI

class InferenceRequestViewModel: ObservableObject {
    enum InclusiveRelationship {
        case leftContainsRight, rightContainsLeft, none
    }

    var inferenceQuery = Inference()

    func requestInference(env: AppEnvironment, sharedData: Binding<CameraTabView.SharedData>) {
        Inference.requestInference(image: sharedData.wrappedValue.originalImage) { result in
            switch result {
            case .success(let data):
                var foodobjlist = [Inference.ResponseStruct]()
                var nonfoodobjlist = [Inference.ResponseStruct]()
                var result = [Inference.ResponseStruct]()

                for obj in data.data! {
                    if obj.class_num == Inference.ClassEnum.food.rawValue {
                        foodobjlist.append(obj)
                    } else {
                        nonfoodobjlist.append(obj)
                    }
                }

                for nfobj in nonfoodobjlist {
                    for fobj in foodobjlist {
                        let area1 = CGRect(x: nfobj.xpos,
                                           y: nfobj.ypos,
                                           width: nfobj.width,
                                           height: nfobj.height)
                        let area2 = CGRect(x: fobj.xpos,
                                           y: fobj.ypos,
                                           width: fobj.width,
                                           height: fobj.height)

                        let sim = self.getAreaSimilarity(area1: area1, area2: area2)

                        var robj = fobj
                        if sim > 0.8 {
                            robj.class_num = nfobj.class_num

                            if result.contains(where: { $0.id == robj.id }) {
                                result.remove(at: result.firstIndex(where: { $0.id == robj.id })!)
                            }
                            result.append(robj)
                        } else {
                            if !result.contains(where: { $0.id == robj.id }) {
                                result.append(robj)
                            }
                        }
                    }
                }
                sharedData.wrappedValue.inferenceData = result
            case .failure(let error):
                sharedData.wrappedValue.inferenceData.removeAll()
                print(error.localizedDescription)
            }

            Shared.viewMessageExchanger.sendMessageTo(viewId: .cameraTabView, message: [
                "changeView": ViewMessageExchanger.ViewEnum.photoMatchView
            ])
        }
    }

    func getAreaSimilarity(area1: CGRect, area2: CGRect) -> CGFloat {
        let iarea = area1.intersection(area2)

        let area1weight = area1.width * area1.height
        let area2weight = area2.width * area2.height
        let iareaweight = iarea.width * iarea.height

        return iareaweight / (area1weight + area2weight - iareaweight)
    }

    func getInclsiveRelationship(area1: CGRect, area2: CGRect) -> InclusiveRelationship {
        if area1.minX <= area2.minX && area2.maxX <= area1.maxX {  // X coordinate check (area1 contains area2)
            if area1.minY <= area2.minY && area2.maxY <= area1.maxY {  // Y coordinate check (area1 contains area2)
                return .leftContainsRight
            } else {
                return .none
            }
        } else if area2.minX <= area1.minX && area1.maxX <= area2.maxX {  // X coordinate check (area2 contains area1)
            if area2.minY <= area1.minY && area1.maxY <= area2.maxY {  // Y coordinate check (area2 contains area1)
                return .rightContainsLeft
            } else {
                return .none
            }

        } else {
            return .none
        }
    }
}
