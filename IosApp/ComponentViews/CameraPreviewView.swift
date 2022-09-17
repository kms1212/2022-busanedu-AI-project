//
//  CameraPreviewView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/29.
//

import UIKit
import SwiftUI
import AVFoundation
import AudioToolbox

struct CameraPreviewView: View {
    @EnvironmentObject var env: AppEnvironment

    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.scenePhase) private var scenePhase

    var cameraManager = CameraManager()

    var completion: (UIImage) -> Void

    @State var showCameraView = true

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                if showCameraView {
                    CameraView(cameraManager: cameraManager) { result in
                        switch result {
                        case .success(let photo):
                            if let data = photo.fileDataRepresentation() {
                                var image = CIImage(data: data)!
                                image = image.oriented(.right)

                                let height = (3 / 4) * image.extent.width
                                let starty = (image.extent.height / 2) - (height / 2)

                                image = image.cropped(to: .init(x: 0,
                                                                y: starty,
                                                                width: image.extent.width,
                                                                height: height))
                                completion(UIImage(ciImage: image).resizeCI(width: 640)!)
                            } else {
                                print("Error converting to UIImage from camera result")
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                    .aspectRatio(4 / 3, contentMode: .fit)
                }
                Spacer()
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        cameraManager.capturePhoto()
                    }, label: {
                        Image(systemName: "camera.fill")
                    })
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(30)
                    Spacer()
                }
                Spacer()
                    .frame(height: 40)
            }
        }
        .onChange(of: scenePhase) { _ in
            switch scenePhase {
            case .active:
                showCameraView = false
                showCameraView = true
            default:
                break
            }
        }
    }

    struct CameraView: UIViewControllerRepresentable {
        typealias UIViewControllerType = UIViewController

        let cameraManager: CameraManager
        let completion: (Result<AVCapturePhoto, Error>) -> Void

        func makeUIViewController(context: Context) -> UIViewController {
            cameraManager.start(delegate: context.coordinator) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
            }

            let viewController = UIViewController()
            viewController.view.backgroundColor = .black
            viewController.view.layer.addSublayer(cameraManager.previewLayer)
            return viewController
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self, completion: completion)
        }

        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
            cameraManager.previewLayer.frame = uiViewController.view.bounds
        }

        class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
            let parent: CameraView

            private var completion: (Result<AVCapturePhoto, Error>) -> Void

            init(_ parent: CameraView, completion: @escaping (Result<AVCapturePhoto, Error>) -> Void) {
                self.parent = parent
                self.completion = completion
            }

            func photoOutput(_ output: AVCapturePhotoOutput,
                             didFinishProcessingPhoto photo: AVCapturePhoto,
                             error: Error?) {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                completion(.success(photo))
            }

            func photoOutput(_ output: AVCapturePhotoOutput,
                             willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
                AudioServicesDisposeSystemSoundID(1108)
            }
        }
    }
}
