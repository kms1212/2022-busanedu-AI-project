//
//  BestOfTheDay.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/02.
//

import SwiftUI

struct BestOfTheDayView: View {
    @ObservedObject var viewModel = BestOfTheDayViewModel()

    var body: some View {
        if let mealData = viewModel.mealData.getData {
            if let schoolData = viewModel.schoolData.getData {
                HStack {
                    NavigationLink(destination: MealDetailView(mealid: mealData.data!.mealid)) {
                        VStack {
                            HStack {
                                Text(schoolData.data!.data[0].school_name)
                                    .font(.customFont(forTextStyle: .title).weight(.bold))
                                Spacer()
                            }
                            HStack {
                                Text("득표수 1위!")
                                    .font(.customFont(forTextStyle: .subheadline))
                                Spacer()
                            }
                        }
                        Image(systemName: "hand.thumbsup.fill")
                        Text(String(mealData.data!.likecnt))
                            .font(.customFont(forTextStyle: .body))
                    }
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxHeight: .infinity)
                .frame(height: 120)
                .background(LinearGradient(colors: [.red, .orange],
                                           startPoint: .bottomLeading,
                                           endPoint: .topTrailing))
                .cornerRadius(20)
            } else if viewModel.schoolData.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxHeight: .infinity)
                .frame(height: 120)
                .background(Constants.unavailableGradient)
                .cornerRadius(20)
            } else if viewModel.schoolData.isWaiting {
                Text("")
                    .onAppear {
                        viewModel.refreshSchoolData(schoolcode1: mealData.data!.schoolcode1,
                                                    schoolcode2: mealData.data!.schoolcode2)
                    }
            }
        } else if viewModel.mealData.isLoading {
            HStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxHeight: .infinity)
            .frame(height: 120)
            .background(Constants.unavailableGradient)
            .cornerRadius(20)
        } else if viewModel.mealData.isWaiting {
            Text("")
                .onAppear {
                    viewModel.refreshMealData()
                }
        }
    }
}
