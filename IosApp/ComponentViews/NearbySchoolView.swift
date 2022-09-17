//
//  NearbySchoolView.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/03.
//

import SwiftUI
import MarqueeText

struct NearbySchoolView: View {
    @ObservedObject var viewModel = NearbySchoolViewModel()

    let schoolcode1: String
    let schoolcode2: String

    @ViewBuilder var loadingView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(0...4, id: \.self) { _ in
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(width: 160, height: 210)
                    .background(Constants.unavailableGradient)
                    .cornerRadius(20)
                }
            }
        }
    }

    var body: some View {
        VStack {
            HStack {
                Text("주변 학교")
                    .font(.customFont(forTextStyle: .title2).bold())
                Spacer()
            }

            switch viewModel.nbsData {
            case .success:
                switch viewModel.nbsMealData {
                case .success(let nbsMealData):
                    ScrollView(.horizontal) {
                        HStack(spacing: 15) {
                            ForEach(nbsMealData, id: \.school.id) { content in
                                if let meal = content.meal.data {
                                    VStack {
                                        Image(uiImage: content.mealImage ?? UIImage(named: "Image")!)
                                            .resizable()
                                            .scaledToFit()
                                        Spacer()
                                        VStack {
                                            HStack {
                                                MarqueeText(text: content.school.school_name,
                                                            font: .customFont(forTextStyle: .title3),
                                                            leftFade: 10,
                                                            rightFade: 10,
                                                            startDelay: 2)
                                                Spacer()
                                            }
                                            HStack {
                                                NavigationLink(destination: MealDetailView(mealid: meal.mealid)) {
                                                    VStack {
                                                        Text("자세히 보기")
                                                            .font(.customFont(forTextStyle: .footnote))
                                                    }
                                                }
                                                Spacer()
                                                Button(action: { }, label: {
                                                    Image(systemName: "hand.thumbsup.fill")
                                                    Text(String(meal.likecnt))
                                                        .font(.customFont(forTextStyle: .body))
                                                })
                                                .foregroundColor(.primary)
                                            }
                                        }
                                        .padding([.horizontal], 15)
                                        Spacer()
                                    }
                                    .frame(width: 160, height: 210)
                                    .background(Color(uiColor: .systemGray6))
                                    .cornerRadius(20)
                                }
                            }
                        }
                    }
                case .failure:
                    VStack {
                        Text("최근 24시간 동안의 급식 정보가 없습니다.")
                    }
                    .frame(height: 210)
                case .loading:
                    loadingView
                case .waiting:
                    CodeProxyView {
                        viewModel.refreshNbsMealData()
                    }
                }
            case .failure:
                Text("failure: nbsdata")
            case .loading:
                loadingView
            case .waiting:
                CodeProxyView {
                    viewModel.refreshNbsData(schoolcode1: schoolcode1,
                                             schoolcode2: schoolcode2)
                }
            }
        }
    }
}
