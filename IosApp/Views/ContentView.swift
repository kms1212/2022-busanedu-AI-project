//
//  ContentView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/26.
//

import Foundation
import SwiftUI
import Alamofire

struct ContentView: View {
    @ObservedObject var env: AppEnvironment

    @State var ready = false
    @State var showingAlert = false
    @State var childView: ViewMessageExchanger.ViewEnum = .none

    init() {
        self.env = AppEnvironment()
    }

    func checkServerStatus() -> Bool {
        let semaphore = DispatchSemaphore(value: 0)
        APIRequestManager.session.request(Constants.apiurl).validate().response { _ in
            semaphore.signal()
        }.resume()
        semaphore.wait()
        return true
    }

    var body: some View {
        VStack {
            if ready {
                switch childView {
                case .introView:
                    IntroView().environmentObject(env)
                case .mainView:
                    MainView().environmentObject(env)
                case .loginView:
                    LoginView().environmentObject(env)
                default:
                    ErrorView()
                }
            } else {
                ProgressView()
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("네트워크 연결 확인"),
                  message: Text("네트워크에 연결할 수 없습니다."),
                  dismissButton: .destructive(Text("확인"),
                                              action: {
                                                          exit(0)
                                                      }))
        }
        .onAppear {
            env.accountSession.tryLoginWithCookie()

            childView = UserDefaults.standard.bool(forKey: "isNotFirstLaunch") ?
                (env.accountSession.userInfo.data != nil ? .mainView : .loginView) : .introView
            if let reachable = Shared.networkReachabilityManager?.isReachable {
                self.showingAlert = !reachable
                if !reachable {
                    childView = .none
                }
            }

            Shared.viewMessageExchanger.setMessageListener(viewId: .contentView) { msg in
                withAnimation {
                    if let viewDest = msg["changeView"] {
                        childView = (viewDest as? ViewMessageExchanger.ViewEnum)!
                    }
                }
            }

            ready = true
        }
    }
}
