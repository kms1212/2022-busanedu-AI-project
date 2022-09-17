//
//  AppEnvironment.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/08.
//

import Foundation
import SwiftUI
import Combine

class AppEnvironment: ObservableObject {
    @Published var accountSession = AccountSession()
    @Published var alertQueue = [(String, UUID)]()

    var anyCancellable: AnyCancellable?

    init() {
        anyCancellable = accountSession.objectWillChange.sink { [weak self] (_) in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
    }

    func addToast(_ message: String) {
        alertQueue.append((message, UUID()))
    }

    func removeToast(_ uuid: UUID) {
        for (idx, alert) in alertQueue.enumerated() where alert.1 == uuid {
            alertQueue.remove(at: idx)
        }
    }
}
