//
//  LoginViewModel.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/09.
//

import Foundation
import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    enum FocusField: Hashable {
        case id, password
    }

    @Published var profile = UserProfile()
    @Published var userid = ""
    @Published var password = ""
    @Published var uidpass = false
    @Published var showmodal = false
    @Published var showsignup = true
    @Published var uidfail = false
    @Published var pwfail = false
    @Published var focusedField: FocusField?

    func updateUserProfile() {
        UserProfile.getProfile(userid: userid) { result in
            switch result {
            case .success(let data):
                self.profile = data

                withAnimation {
                    self.uidpass.toggle()
                }
                self.focusedField = .password
            case .failure(let error):
                withAnimation {
                    self.uidfail = true
                }
                print(error.localizedDescription)
            }
        }
    }

    func requestLogin(env: AppEnvironment) {
        env.accountSession.login(username: userid, password: password) { result in
            switch result {
            case .success:
                withAnimation {
                    Shared.viewMessageExchanger.sendMessageTo(viewId: .contentView, message: [
                        "changeView": ViewMessageExchanger.ViewEnum.mainView
                    ])
                }
            case .failure:
                self.pwfail = true
            }
        }
    }
}
