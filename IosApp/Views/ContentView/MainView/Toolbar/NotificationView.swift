//
//  NotificationView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/03.
//

import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var env: AppEnvironment

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack {
                    HStack {
                        Text("오늘")
                            .font(.bold(.customFont(forTextStyle: .title2))())
                            .padding([.horizontal, .top])
                        Spacer()
                    }

                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(20)

                VStack {
                    HStack {
                        Text("어제")
                            .font(.bold(.customFont(forTextStyle: .title2))())
                            .padding([.horizontal, .top])
                        Spacer()
                    }

                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(20)

                VStack {
                    HStack {
                        Text("이번 주")
                            .font(.bold(.customFont(forTextStyle: .title2))())
                            .padding([.horizontal, .top])
                        Spacer()
                    }

                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                    NotificationListItemView(image: UIImage(named: "Image")!,
                                             title: "Title", content: "Content", action: {})
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(20)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("알림")
        .onAppear {
            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": false
            ])
        }
    }
}
