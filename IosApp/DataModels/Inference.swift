//
//  Inference.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/08.
//

import Foundation
import Alamofire
import SwiftUI
import Starscream

struct Inference {
// swiftlint:disable identifier_name
    struct ResponseStruct: Codable, Equatable, Identifiable {
        let id: Int
        var class_num: Int
        var xpos: Int
        var ypos: Int
        var width: Int
        var height: Int
    }

    struct UploadStruct: Codable, Equatable, Identifiable {
        let id: Int
        var class_num: Int
        var xpos: Int
        var ypos: Int
        var width: Int
        var height: Int
        var menuid: Int
    }

    enum ClassEnum: Int {
        case bread = 0, food = 1, fruit = 2, noodle = 3, porridge = 4, processed = 5, rice = 6, rice_cake = 7, soup = 8
    }
// swiftlint:enable identifier_name

    struct MessageStruct: Codable {
        let message: String
    }

    var data: [ResponseStruct]?

    static func requestInference(image: UIImage,
                                 _ completion: @escaping (Result<Self, Error>) -> Void) {
        let uploadImage = image.size.width == 640 ? image : image.resizeCI(width: 640)!
        let wsDelegate = InferenceWebSocketDelegate()

        APIRequestManager.session.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(uploadImage.pngData()!,
                                     withName: "image",
                                     fileName: "image.png",
                                     mimeType: "image/png")
        }, to: Constants.apiurl + "detect/request", method: .post).validate()
            .responseData(queue: .global(qos: .userInitiated)) { result1 in
            var result: Result<Self, Error>?

            switch result1.result {
            case .success:
                let semaphore = DispatchSemaphore(value: 0)

                wsDelegate.getInferenceData { result2 in
                    switch result2 {
                    case .success(let data):
                        result = .success(Inference(data: data))
                    case .failure(let error):
                        result = .failure(error)
                    }
                    semaphore.signal()
                }
                semaphore.wait()
            case .failure(let error):
                result = .failure(error)
                print(error.localizedDescription)
            }

            completion(result!)
        }.resume()
    }

    static func uploadInference(mealid: Int, image: UIImage, inferenceData: [UploadStruct],
                                _ completion: @escaping (Result<Void, Error>) -> Void) {
        let uploadImage = image.size.width == 640 ? image : image.resizeCI(width: 640)!
        var result: Result<Void, Error>?

        let semaphore = DispatchSemaphore(value: 0)

        do {
            let jsonData = try Shared.jsonEncoder.encode(inferenceData)

            APIRequestManager.session.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(String(mealid).data(using: .utf8)!,
                                         withName: "mealid")
                multipartFormData.append(uploadImage.pngData()!,
                                         withName: "mealimage",
                                         fileName: "mealimage.png",
                                         mimeType: "image/png")
                multipartFormData.append(jsonData,
                                         withName: "jsondata",
                                         mimeType: "application/json")
            }, to: Constants.apiurl + "meal/inference").validate()
                .response(queue: .global(qos: .userInitiated)) { response in
                    switch response.result {
                    case .success:
                        result = .success(())
                    case .failure(let error):
                        print(error.localizedDescription)
                        result = .failure(error)
                    }
                    semaphore.signal()
                }
            semaphore.wait()
        } catch let error {
            print(error.localizedDescription)
            result = .failure(error)
        }

        completion(result!)
    }

    class InferenceWebSocketDelegate: WebSocketDelegate {

        var request: URLRequest
        var websocket: WebSocket

        static var jsonEncoder = JSONEncoder()
        static var jsonDecoder = JSONDecoder()

        private var completion: (Result<[ResponseStruct], Error>) -> Void = { _ in }
        private var result: Result<[ResponseStruct], Error>?

        init() {
            request = URLRequest(url: URL(string: Constants.apiurl + "ws/detect/response")!)
            websocket = WebSocket(request: request)
            websocket.delegate = self
        }

        func getInferenceData(_ completion: @escaping (Result<[ResponseStruct], Error>) -> Void) {
            websocket.connect()

            self.completion = completion
        }

        func sendMessage(_ msg: String) {
            do {
                let message = MessageStruct(message: msg)
                websocket.write(string: String(data: try Self.jsonEncoder.encode(message), encoding: .utf8)!)
            } catch let exception {
                print(exception.localizedDescription)
            }
        }

        func decodeMessage(_ jsonData: String) -> String? {
            do {
                let message = try Self.jsonDecoder.decode(MessageStruct.self, from: jsonData.data(using: .utf8)!)
                return message.message
            } catch let exception {
                print(exception.localizedDescription)
                return nil
            }
        }

        internal func onTextReceived(text: String) {
            do {
                let msg = decodeMessage(text)
                switch msg {
                case "READY":
                    sendMessage("START")
                case "OK":
                    break
                case "INFERENCEOK":
                    sendMessage("GETDATA")
                case nil:
                    break
                default:
                    let infdata = try Shared.jsonDecoder.decode([ResponseStruct].self,
                                                                from: msg!.data(using: .utf8)!)
                    result = .success(infdata)
                    completion(result!)
                    websocket.disconnect()
                }
            } catch let error {
                print("Error while decoding or encoding: \(error.localizedDescription)")
            }
        }

        internal func didReceive(event: WebSocketEvent, client: WebSocket) {
            switch event {
            case .text(let text):
                onTextReceived(text: text)
            case .disconnected(let reason, let code):
                if result == nil {
                    print("Websocket unexpectedly disconnected: \(reason) with code: \(code)")
                    result = .failure(Starscream.ErrorType.serverError)
                    completion(result!)
                }
            default:
                break
            }
        }
    }
}
