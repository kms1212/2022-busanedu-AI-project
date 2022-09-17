//
//  ExploreTabView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/03.
//

import SwiftUI
import RefreshableScrollView
import Introspect

struct ExploreTabView: View {
    @EnvironmentObject var env: AppEnvironment

    @StateObject var viewModel = ExploreTabViewModel()

    var body: some View {
        VStack {
            switch viewModel.gridData {
            case .success(let gridData):
                RefreshableScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 2, alignment: .top)], spacing: 2) {
                        ForEach(Array(gridData.enumerated()), id: \.0) { _, meal in
                            NavigationLink(destination: MealDetailView(mealid: meal.mealInfo.mealid)) {
                                Image(uiImage: meal.inferenceImage)
                                    .resizable()
                                    .aspectRatio(4 / 3, contentMode: .fit)
                            }
                        }
                    }
                }
                .refreshable {
                    viewModel.gridData = .waiting
                }
            case .failure:
                EmptyView()
            case .loading:
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 2, alignment: .top)], spacing: 2) {
                        ForEach(0 ..< 10, id: \.self) { _ in
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                                Spacer()
                            }
                            .background(Constants.unavailableGradient)
                            .aspectRatio(4 / 3, contentMode: .fill)
                        }
                    }
                }
                .introspectScrollView { scrollView in
                    scrollView.isScrollEnabled = false
                }
            case .waiting:
                CodeProxyView {
                    viewModel.refreshGridData(schoolcode1: env.accountSession.userInfo.data!.schoolcode1,
                                              schoolcode2: env.accountSession.userInfo.data!.schoolcode2)
                }
            }
        }
        .onAppear {
            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": true
            ])
        }
    }
}
