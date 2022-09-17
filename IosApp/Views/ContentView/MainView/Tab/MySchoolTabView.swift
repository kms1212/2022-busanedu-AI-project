//
//  MySchoolTabView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/03.
//

import SwiftUI

struct MySchoolTabView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        ScrollView {
            VStack {

            }
        }
        .onAppear {
            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": true
            ])
        }
    }
}
