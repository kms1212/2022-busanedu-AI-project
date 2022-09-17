//
//  AgreementView.swift
//  iosApp
//
//  Created by 권민수 on 2022/06/05.
//

import SwiftUI

struct AgreementView: View {
    @EnvironmentObject var env: AppEnvironment

    @State var agg1: Bool = false
    @State var agg2: Bool = false
    @State var agg3: Bool = false

    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Spacer()
                HStack {
                    CheckBox(isChecked: $agg1) {
                        Text("Text")
                            .font(.customFont(forTextStyle: .body))
                    }
                    Spacer()
                    Button(action: { }, label: {
                        Image(systemName: "arrow.up.right.square")
                    })
                }
                HStack {
                    CheckBox(isChecked: $agg2) {
                        Text("Text")
                            .font(.customFont(forTextStyle: .body))
                    }
                    Spacer()
                    Button(action: { }, label: {
                        Image(systemName: "arrow.up.right.square")
                    })
                }
                HStack {
                    CheckBox(isChecked: $agg3) {
                        Text("Text")
                            .font(.customFont(forTextStyle: .body))
                    }
                    Spacer()
                    Button(action: { }, label: {
                        Image(systemName: "arrow.up.right.square")
                    })
                }
                Spacer()
                .padding()
            }
            .frame(maxWidth: 300)
            HStack {
                Spacer()
                Button(action: {
                    Shared.viewMessageExchanger.sendMessageTo(viewId: .signUpView, message: [
                        "changeView": ViewMessageExchanger.ViewEnum.userDataView
                    ])
                }, label: {
                    Text("다음")
                        .font(.customFont(forTextStyle: .body))
                })
                .disabled(!(agg1 && agg2 && agg3))
            }
            .padding()
        }
        .padding()
        .onAppear {
        }
    }
}
