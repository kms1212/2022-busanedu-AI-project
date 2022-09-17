//
//  EmailVerificationView.swift
//  iosApp
//
//  Created by 권민수 on 2022/06/03.
//

import SwiftUI

struct EmailVerificationView: View {
    @EnvironmentObject var env: AppEnvironment

    var onDismiss: () -> Void = {}

    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Lottie(filename: "check-email", loopMode: .playOnce)
                .scaledToFit()
                .frame(width: Constants.vmin / 3)
            Text("Please verify your email address and login.")
                .font(.bold(.customFont(forTextStyle: .title2))())
            Spacer()
            Button(action: {
                onDismiss()
            }, label: {
                Text("확인")
                    .font(.customFont(forTextStyle: .body))
            })
            Spacer()
            Spacer()
        }
        .onAppear {
        }
    }
}
