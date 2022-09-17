//
//  PhotoCaptureView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/05.
//

import SwiftUI

struct PhotoCaptureView: View {
    @EnvironmentObject var env: AppEnvironment

    @Binding var sharedData: CameraTabView.SharedData

    func imageHandler(image: UIImage) {
        self.sharedData.originalImage = image.resizeCI(width: 640)!
        Shared.viewMessageExchanger.sendMessageTo(viewId: .cameraTabView, message: [
            "changeView": ViewMessageExchanger.ViewEnum.inferenceRequestView
        ])
    }

    var body: some View {
        ZStack {
            CameraPreviewView(completion: imageHandler)
                .background(Color.black)

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        let override = UserDefaults.standard.string(forKey: "image_override")

                        if let override = override {
                            imageHandler(image: UIImage(named: override)!)
                        }
                    }, label: {
                        Text("Skip")
                            .font(.customFont(forTextStyle: .body))
                    })
                    .buttonStyle(BorderedButtonStyle())
                }
                .padding()
                Spacer()
            }
        }
    }
}
