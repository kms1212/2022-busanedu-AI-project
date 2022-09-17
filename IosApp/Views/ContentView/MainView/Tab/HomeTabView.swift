//
//  HomeTabView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/27.
//

import SwiftUI
import MarqueeText
import RefreshableScrollView

struct HomeTabView: View {
    @EnvironmentObject var env: AppEnvironment

    @State var showList = false

    var body: some View {
        RefreshableScrollView(showsIndicators: false) {
            VStack {
                if showList {
                    BestOfTheDayView()
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding([.bottom], 5)

                    HStack(spacing: 15) {
                        SmallMealView(schoolcode1: env.accountSession.userInfo.data!.schoolcode1,
                                      schoolcode2: env.accountSession.userInfo.data!.schoolcode2)
                        .frame(minWidth: 0, maxWidth: .infinity)

                        NavigationLink(destination: EmptyView()) {
                            HStack {
                                Text("우리 학교 식단 홍보하러 가기")
                                    .font(.customFont(forTextStyle: .title3))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .foregroundColor(.primary)
                        }
                        .padding()
                        .frame(maxHeight: .infinity)
                        .frame(height: 120)
                        .background(GeometryReader { geo in
                            Image("Banner1bg")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .frame(width: geo.size.width)
                                .position(x: 120, y: 60)
                        })
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(20)
                        .onTapGesture {
                            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                                "changeView": ViewMessageExchanger.ViewEnum.cameraTabView
                            ])
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding([.bottom], 5)

                    NearbySchoolView(schoolcode1: env.accountSession.userInfo.data!.schoolcode1,
                                     schoolcode2: env.accountSession.userInfo.data!.schoolcode2)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .padding([.bottom], 5)

                    HStack {
                        Spacer()
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                    .frame(height: 300)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(20)
                    .listRowSeparator(.hidden)
                    .padding([.bottom], 5)
                }
                Spacer()
                    .frame(height: 70)
            }
        }
        .refreshable {
            showList = false
            showList = true
        }
        .padding([.horizontal])
        .onAppear {
            showList = true
            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": true
            ])
        }
    }
}
