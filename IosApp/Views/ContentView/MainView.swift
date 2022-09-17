//
//  MainView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/26.
//

import SwiftUI
import Foundation

struct MainView: View {
    @EnvironmentObject var env: AppEnvironment

    @State var currentTab: ViewMessageExchanger.ViewEnum = .homeTabView {
        willSet(newValue) {
            if currentTab != newValue {
                previousTab = currentTab
            }
        }
    }
    @State var previousTab: ViewMessageExchanger.ViewEnum = .homeTabView
    @State var navSelection: Int?
    @State var showTabBar: Bool = true

    @ViewBuilder
    func tabitem<Content: View>(@ViewBuilder content: () -> Content, title: String = "") -> some View {
        NavigationView {
            content()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        NavigationLink(destination: UserMenuView().environmentObject(env),
                                       tag: 1, selection: $navSelection) {
                            ProfileImageView(image: env.accountSession.userInfo.profileImage)
                                .border(width: 2)
                                .frame(width: 30, height: 30)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: NotificationView().environmentObject(env),
                                       tag: 2, selection: $navSelection) {
                            Image(systemName: "bell.fill")
                        }
                        .foregroundColor(.yellow)
                    }
                }
                .navigationBarHidden(false)
                .navigationBarTitleDisplayMode(title == "" ? .inline : .large)
                .navigationTitle(title)
        }
        .onDisappear {
            navSelection = nil
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    func tabButton<Content: View>(@ViewBuilder content: () -> Content,
                                  size: CGSize = .init(width: 27, height: 27),
                                  tag: ViewMessageExchanger.ViewEnum) -> some View {
        Button(action: {
            withAnimation {
                Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                    "changeView": tag
                ])
            }
        }, label: {
            Spacer()
            Rectangle()
                .opacity(0)
                .overlay {
                    content()
                        .foregroundColor(currentTab == tag ? .primary: Color(uiColor: .systemGray))
                }
                .frame(width: size.width, height: size.height)
            Spacer()
        })
        .buttonStyle(PlainButtonStyle())
    }

    var body: some View {
        ZStack {
            switch currentTab {
            case .homeTabView:
                tabitem(content: {
                    HomeTabView()
                    .environmentObject(env)
                }, title: "홈")

            case .rankingTabView:
                tabitem(content: {
                    RankingTabView()
                    .environmentObject(env)
                }, title: "랭킹")
            case .cameraTabView:
                tabitem(content: {
                    ZStack {
                        CameraTabView()
                        .environmentObject(env)

                        VStack {
                            HStack {
                                Button(action: {
                                    Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                                        "changeView": previousTab
                                    ])
                                }, label: {
                                    Image(systemName: "arrow.left")
                                })
                                .buttonStyle(BorderedButtonStyle())
                                Spacer()
                            }
                            .padding()
                            Spacer()
                        }
                    }
                })
            case .exploreTabView:
                tabitem(content: {
                    ExploreTabView()
                    .environmentObject(env)
                }, title: "둘러보기")
            case .mySchoolTabView:
                tabitem(content: {
                    MySchoolTabView()
                    .environmentObject(env)
                }, title: "우리 학교")
            default:
                ErrorView()
            }

            VStack {
                Spacer()
                ToastView().environmentObject(env)
                Spacer()
                    .frame(height: 5)
                if showTabBar {
                    HStack {
                        tabButton(content: {
                            Image(systemName: "house" + (currentTab == .homeTabView ? ".fill" : ""))
                                .resizable()
                                .scaledToFit()
                        }, tag: .homeTabView)
                        tabButton(content: {
                            Image(systemName: "chart.bar" + (currentTab == .rankingTabView ? ".fill" : ""))
                                .resizable()
                                .scaledToFit()
                        }, tag: .rankingTabView)
                        tabButton(content: {
                            Image(systemName: "camera" + (currentTab == .cameraTabView ? ".fill" : ""))
                                .resizable()
                                .scaledToFit()
                        }, tag: .cameraTabView)
                        tabButton(content: {
                            Image(systemName: "globe")
                                .resizable()
                                .scaledToFit()
                        }, tag: .exploreTabView)
                        tabButton(content: {
                            Image(systemName: "graduationcap" + (currentTab == .mySchoolTabView ? ".fill" : ""))
                                .resizable()
                                .scaledToFit()
                        }, tag: .mySchoolTabView)
                    }
                    .padding([.horizontal], 20)
                    .padding([.top], 15)
                    .padding([.bottom], 40)
                    .background(Material.bar)
                    .cornerRadius(15, corners: [.topLeft, .topRight])
                    .shadow(radius: 5)
                    .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            Shared.viewMessageExchanger.setMessageListener(viewId: .mainView) { msg in
                withAnimation {
                    if let viewDest = msg["changeView"] {
                        currentTab = (viewDest as? ViewMessageExchanger.ViewEnum)!
                    }

                    if let showTabBar = msg["showTabBar"] {
                        self.showTabBar = (showTabBar as? Bool)!
                    }
                }
            }
        }
    }
}
