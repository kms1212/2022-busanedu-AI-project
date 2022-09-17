//
//  ToastView.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/06.
//

import SwiftUI

struct ToastView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        VStack {
            ForEach(env.alertQueue, id: \.1) { message in
                VStack {
                    HStack {
                        VStack {
                            Text(message.0)
                                .font(.customFont(forTextStyle: .title3))
                        }
                        Spacer()
                        Button(action: {
                            withAnimation(.spring()) {
                                env.removeToast(message.1)
                            }
                        }, label: {
                            Rectangle()
                                .opacity(0)
                                .overlay {
                                    Image(systemName: "xmark")
                                        .imageScale(.large)
                                }
                                .frame(width: 30, height: 30)
                        })
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding()
                }
                .background(Material.bar)
                .cornerRadius(10)
                .shadow(radius: 3)
                .padding([.horizontal])
                .transition(.move(edge: .trailing))
            }
        }
    }
}
