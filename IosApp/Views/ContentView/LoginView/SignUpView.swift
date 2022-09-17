//
//  SignUpView.swift
//  iosApp
//
//  Created by 권민수 on 2022/06/03.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var env: AppEnvironment

    @State var userData: DetailedUserProfile?
    @State var childView: ViewMessageExchanger.ViewEnum = .agreementView

    var onDismiss: () -> Void = {}

    var body: some View {
        VStack {
            switch childView {
            case .agreementView:
                AgreementView().environmentObject(env)
            case .userDataView:
                UserDataView(userData: $userData).environmentObject(env)
            case .personalDataView:
                PersonalDataView(userData: $userData).environmentObject(env)
            case .emailVerificationView:
                EmailVerificationView(onDismiss: onDismiss).environmentObject(env)
            default:
                ErrorView()
            }
        }
        .onAppear {
            Shared.viewMessageExchanger.setMessageListener(viewId: .signUpView) { msg in
                withAnimation {
                    if let viewDest = msg["changeView"] {
                        childView = (viewDest as? ViewMessageExchanger.ViewEnum)!
                    }
                }
            }
        }
    }
}
