//
//  RankingTabView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/03.
//

import SwiftUI
import RefreshableScrollView
import MarqueeText
import UIKit

struct RankingTabView: View {
    @EnvironmentObject var env: AppEnvironment

    @StateObject var viewModel: RankingTabViewModel = RankingTabViewModel()

    @State var showList = true

    func refresh() {
        DispatchQueue.main.async {
            viewModel.refreshRawMealRanking()
            viewModel.mealRanking = .waiting
        }
    }

    var body: some View {
        RefreshableScrollView {
            LazyVStack {
                switch viewModel.rawMealRanking {
                case .success:
                    switch viewModel.mealRanking {
                    case .success(let mealRanking):
                        VStack(spacing: 5) {
                            ForEach(Array(mealRanking.enumerated()), id: \.0) { idx, data in
                                NavigationLink(destination: MealDetailView(mealid: data.mealData.data!.mealid)
                                    .environmentObject(env)) {
                                    VStack {
                                        HStack {
                                            if idx == 0 && viewModel.page == 0 {
                                                Image(systemName: "crown.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.yellow)
                                            } else {
                                                Text(String(30 * viewModel.page + idx + 1))
                                                    .font(.customFont(forTextStyle: .title))
                                            }
                                            VStack {
                                                HStack {
                                                    Text(data.schoolData.data!.data[0].school_name)
                                                        .font(.customFont(forTextStyle: .body))
                                                }
                                                MarqueeText(text: data.mealData.data!.menunames
                                                                      .map({$0.menuname_filtered})
                                                                      .joined(separator: ", "),
                                                            font: .customFont(forTextStyle: .body),
                                                            leftFade: 10,
                                                            rightFade: 10,
                                                            startDelay: 1)
                                            }
                                            .padding([.leading])

                                            Image(systemName: "hand.thumbsup.fill")
                                            Text(String(data.mealData.data!.likecnt))
                                                .font(.customFont(forTextStyle: .body))
                                        }
                                        .frame(height: 60)
                                    }
                                }
                                    .padding([.horizontal])

                                if idx < mealRanking.count - 1 {
                                    Divider()
                                }
                            }
                        }
                        .padding([.vertical], 5)
                        .foregroundColor(.primary)
                        .background(Color(uiColor: .systemGray6))
                        .cornerRadius(20)

                        HStack {
                            Spacer()
                            Button(action: {
                                if viewModel.page > 0 {
                                    viewModel.page -= 1
                                    refresh()
                                }
                            }, label: {
                                Image(systemName: "chevron.left")
                            })
                            .disabled(viewModel.page <= 0)
                            .buttonStyle(BorderedButtonStyle())
                            Text(String(viewModel.page))
                            Button(action: {
                                viewModel.page += 1
                                refresh()
                            }, label: {
                                Image(systemName: "chevron.right")
                            })
                            .buttonStyle(BorderedButtonStyle())
                            Spacer()
                        }
                    case .loading:
                        ProgressView()
                    case .waiting:
                        CodeProxyView {
                            viewModel.refreshMealRanking()
                        }
                    default:
                        EmptyView()
                    }
                case .waiting:
                    CodeProxyView {
                        viewModel.refreshRawMealRanking()
                    }
                default:
                    EmptyView()
                }
                Spacer()
                    .frame(height: 70)
            }
            .padding([.horizontal])
        }
        .onAppear {
            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": true
            ])
        }
        .refreshable(action: refresh)
    }
}
