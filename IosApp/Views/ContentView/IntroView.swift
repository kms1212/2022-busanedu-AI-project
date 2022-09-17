//
//  IntroView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/26.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject var env: AppEnvironment

    @State var index = 0

    var body: some View {
        VStack {
            TabView {
                Image("Image")
                    .resizable()
                    .scaledToFill()
                Image("Image")
                    .resizable()
                    .scaledToFill()
                Image("Image")
                    .resizable()
                    .scaledToFill()
                Image("Image")
                    .resizable()
                    .scaledToFill()
                Lottie(filename: "hello", loopMode: .loop)
                    .scaledToFit()
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))

            Button(action: {
                UserDefaults.standard.set(true, forKey: "isNotFirstLaunch")

                Shared.viewMessageExchanger.sendMessageTo(viewId: .contentView, message: [
                    "changeView": ViewMessageExchanger.ViewEnum.loginView
                ])
            }, label: {
                Text("Start")
                    .font(.customFont(forTextStyle: .body))
            })
            Spacer()
                .frame(height: 20)
        }
        .onAppear {
        }
    }
}
