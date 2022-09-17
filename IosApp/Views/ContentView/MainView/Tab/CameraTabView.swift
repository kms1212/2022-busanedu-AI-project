//
//  CameraTabView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/27.
//

import SwiftUI
import UIKit
import PhotosUI

struct CameraTabView: View {
    struct SharedData {
        var originalImage = UIImage()
        var inferenceData = [Inference.ResponseStruct]()
    }

    @EnvironmentObject var env: AppEnvironment

    @State var childView: ViewMessageExchanger.ViewEnum = .photoCaptureView
    @State private var sharedData = SharedData()

    var body: some View {
        VStack {
            switch childView {
            case .photoCaptureView:
                PhotoCaptureView(sharedData: $sharedData).environmentObject(env)
            case .inferenceRequestView:
                InferenceRequestView(sharedData: $sharedData).environmentObject(env)
            case .photoMatchView:
                PhotoMatchView(sharedData: $sharedData).environmentObject(env)
            default:
                ErrorView()
            }
        }.onAppear {
            childView = .photoCaptureView

            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": false
            ])

            Shared.viewMessageExchanger.setMessageListener(viewId: .cameraTabView) { msg in
                withAnimation {
                    if let viewDest = msg["changeView"] {
                        childView = (viewDest as? ViewMessageExchanger.ViewEnum)!
                    }
                }
            }
        }
    }
}
