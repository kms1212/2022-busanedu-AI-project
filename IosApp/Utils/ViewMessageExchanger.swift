//
//  ViewMessageExchanger.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/10.
//

import SwiftUI

class ViewMessageExchanger {
    enum ViewEnum {
        case none
        case contentView
        case agreementView, userDataView, personalDataView, emailVerificationView, agreementDocumentView
        case loginView, userMenuView, notificationView, signUpView
        case homeTabView, cameraTabView, rankingTabView, exploreTabView, mySchoolTabView
        case photoCaptureView, photoMatchView, inferenceRequestView
        case mealDetailView
        case mainView, introView, errorView
    }

    private var messageListener: [ViewEnum: ([String: Any]) -> Void] = [:]

    func setMessageListener(viewId: ViewEnum, _ listener: @escaping ([String: Any]) -> Void) {
        messageListener[viewId] = listener
    }

    func sendMessageTo(viewId: ViewEnum, message: [String: Any]) {
        if let listener = messageListener[viewId] {
            listener(message)
        }
    }
}
