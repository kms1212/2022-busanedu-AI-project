//
//  UserMenuView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/28.
//

import SwiftUI

struct UserMenuView: View {
    @EnvironmentObject var env: AppEnvironment

    @State var showingAlert = false
    @State var dummytoggle = true

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                VStack {
                    HStack {
                        ProfileImageView(image: env.accountSession.userInfo.profileImage)
                            .border(width: 3)
                            .frame(width: 60, height: 60)
                        Text(env.accountSession.userInfo.data!.username)
                            .font(.customFont(forTextStyle: .title2))
                        Spacer()
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: 12, height: 12)
                        // Text(ev.accountSession.userInfo.data!.usertype)
                        //     .font(.caption)
                    }
                    Text(env.accountSession.userInfo.data!.description ?? "")
                        .font(.customFont(forTextStyle: .body))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.background)
                        .cornerRadius(10)
                    HStack {
                        Button(action: { }, label: {
                            Image(systemName: "pencil")
                        })
                        Spacer()
                        Button(action: { }, label: {
                            Image(systemName: "square.and.arrow.up.fill")
                        })
                    }
                    .padding([.top, .horizontal], 5)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(20)
                .padding()

                VStack {
                    HStack {
                        Text("설정")
                            .font(.bold(.customFont(forTextStyle: .body))())
                        Spacer()
                    }
                    VStack {
                        SettingsCategoryListItemView(destination:
                                                        AnyView(EmptyView()),
                                                    iconContent:
                                                        AnyView(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .foregroundColor(.yellow)
                                                                .overlay(
                                                                    Image(systemName: "person")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .padding(6))
                                                                .aspectRatio(1, contentMode: .fit)),
                                                     title: "계정")
                        Divider()
                        SettingsCategoryListItemView(destination:
                                                        AnyView(EmptyView()),
                                                    iconContent:
                                                        AnyView(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .foregroundColor(.yellow)
                                                                .overlay(
                                                                    Image(systemName: "key")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .padding(6))
                                                                .aspectRatio(1, contentMode: .fit)),
                                                     title: "보안")
                        Divider()
                        SettingsCategoryListItemView(destination:
                                                        AnyView(EmptyView()),
                                                    iconContent:
                                                        AnyView(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .foregroundColor(.yellow)
                                                                .overlay(
                                                                    Image(systemName: "bell")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .padding(6))
                                                                .aspectRatio(1, contentMode: .fit)),
                                                     title: "알림")
                        Divider()
                        SettingsCategoryListItemView(destination:
                                                        AnyView(EmptyView()),
                                                    iconContent:
                                                        AnyView(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .foregroundColor(.yellow)
                                                                .overlay(
                                                                    Image(systemName: "info")
                                                                        .resizable()
                                                                        .scaledToFit()
                                                                        .padding(6))
                                                                .aspectRatio(1, contentMode: .fit)),
                                                     title: "정보")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                }
                .padding()
            }

            Button(action: {
                self.showingAlert = true
            }, label: {
                Text("Reset settings & Log-out")
                    .font(.customFont(forTextStyle: .body))
                    .foregroundColor(.white)
            })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Alert"),
                      message: Text("Settings has been reset. Stopping."),
                      primaryButton: .destructive(Text("OK"),
                                                  action: {
                                                              resetSettings()
                                                              env.accountSession.logout()
                                                              exit(0)
                                                          }),
                      secondaryButton: .cancel(Text("Cancel")))
            }
            .padding()
            .background(Color.red)
            .cornerRadius(40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": false
            ])
        }
    }
}
