//
//  CameraManager.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/09.
//

import Foundation
import AVFoundation

class CameraManager {
    var session: AVCaptureSession?
    var delegate: AVCapturePhotoCaptureDelegate?

    let output = AVCapturePhotoOutput()
    let previewLayer = AVCaptureVideoPreviewLayer()

    let classid = UUID()

    func start(delegate: AVCapturePhotoCaptureDelegate, completion: @escaping (Error?) -> Void) {
        self.delegate = delegate
        DispatchQueue.global(qos: .userInteractive).async {
            self.checkPermissions(completion: completion)
        }
    }

    private func checkPermissions(completion: @escaping (Error?) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else { return }
                DispatchQueue.main.async {
                    self?.setupCamera(completion: completion)
                }
            }
        case .restricted:
            break
        case .denied:
            break
        case .authorized:
            setupCamera(completion: completion)
        @unknown default:
            break
        }
    }

    private func setupCamera(completion: @escaping (Error?) -> Void) {
        let session = AVCaptureSession()

        if let device = AVCaptureDevice.default(for: .video) {
            do {
                let input = try AVCaptureDeviceInput(device: device)

                if session.canAddInput(input) {
                    session.addInput(input)
                }

                if session.canAddOutput(output) {
                    session.addOutput(output)
                }

                previewLayer.videoGravity = .resizeAspectFill
                previewLayer.session = session

                session.startRunning()
                self.session = session
            } catch let error {
                completion(error)
            }
        }
    }

    func capturePhoto(with settings: AVCapturePhotoSettings = AVCapturePhotoSettings()) {
        output.capturePhoto(with: settings, delegate: self.delegate!)
    }
}
