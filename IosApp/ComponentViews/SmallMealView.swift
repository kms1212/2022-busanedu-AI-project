//
//  SmallMealView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/08.
//

import SwiftUI
import MarqueeText

struct SmallMealView: View {
    let schoolcode1: String
    let schoolcode2: String

    @ObservedObject var viewModel = SmallMealViewModel()

    private func getBackground(mealTime: Meal.MealTime) -> LinearGradient {
        switch mealTime {
        case .breakfast:
            return LinearGradient(colors: [.orange, .cyan],
                                  startPoint: .bottomLeading,
                                  endPoint: .topTrailing)
        case .lunch:
            return LinearGradient(colors: [.blue, .cyan],
                                  startPoint: .bottomLeading,
                                  endPoint: .topTrailing)
        case .dinner:
            return LinearGradient(colors: [.orange, .indigo],
                                  startPoint: .bottomTrailing,
                                  endPoint: .topLeading)
        case .none:
            return Constants.unavailableGradient
        }
    }

    var body: some View {
        switch viewModel.schoolData {
        case .success(let schoolData):
            switch viewModel.mealData {
            case .success(let mealData):
                VStack {
                    Spacer()
                    HStack {
                        if schoolData.data!.data.count != 0 {
                            MarqueeText(text: schoolData.data!.data[0].school_name,
                                        font: .customFont(forTextStyle: .title2),
                                        leftFade: 10,
                                        rightFade: 10,
                                        startDelay: 1)
                        } else {
                            Text("학교 데이터를 읽어올 수 없습니다.")
                                .font(.customFont(forTextStyle: .body))
                        }
                    }
                    Spacer()
                    HStack {
                        VStack {
                            Spacer()
                            MarqueeText(text: mealData.data!.menunames.map({$0.menuname_filtered}).joined(separator: ", "),
                                        font: .customFont(forTextStyle: .body),
                                        leftFade: 10,
                                        rightFade: 10,
                                        startDelay: 2)
                            Spacer()
                            NavigationLink(destination: MealDetailView(mealid: mealData.data!.mealid)) {
                                VStack {
                                    Text("자세히 보기")
                                        .foregroundColor(.black)
                                        .font(.customFont(forTextStyle: .footnote))
                                }
                            }
                            Spacer()
                        }
                        Spacer()
                        Image(systemName: "hand.thumbsup.fill")
                        Text(String(mealData.data!.likecnt))
                            .font(.customFont(forTextStyle: .body))
                    }
                    .frame(height: 40)
                    Spacer()
                }
                .padding()
                .frame(maxHeight: .infinity)
                .frame(height: 120)
                .background(getBackground(mealTime: Meal.MealTime(rawValue: mealData.data!.mealtime)!))
                .cornerRadius(20)
            case .failure:
                HStack {
                    Text("급식 정보가 없습니다.")
                        .font(.customFont(forTextStyle: .body))
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(getBackground(mealTime: .none))
                .cornerRadius(20)
            case .loading:
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .background(getBackground(mealTime: .none))
                .cornerRadius(20)
            case .waiting:
                CodeProxyView {
                    viewModel.refreshMealData(schoolcode1: schoolcode1, schoolcode2: schoolcode2)
                }
            }
        case .failure:
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Text("학교 데이터를 읽어올 수 없습니다.")
                        .font(.customFont(forTextStyle: .body))
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(getBackground(mealTime: .none))
            .cornerRadius(20)
        case .loading:
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(getBackground(mealTime: .none))
            .cornerRadius(20)
        case .waiting:
            CodeProxyView {
                viewModel.refreshSchoolData(schoolcode1: schoolcode1, schoolcode2: schoolcode2)
            }
        }
    }
}
