//
//  AllergyDetailView.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/11.
//

import SwiftUI

struct AllergyDetailView: View {
    static let allergyFoodInfo = [
        "난류",
        "우유",
        "메밀",
        "땅콩",
        "대두",
        "밀",
        "고등어",
        "게",
        "새우",
        "돼지고기",
        "복숭아",
        "토마토",
        "아황산염",
        "호두",
        "닭고기",
        "쇠고기",
        "오징어",
        "조개류",
        "잣"
    ]

    @EnvironmentObject var env: AppEnvironment

    var mealData: Meal
    var allergyData: MealDetailViewModel.AllergyData

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("알러지 유발 식품 목록")
                    .font(.customFont(forTextStyle: .title3))
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 75), alignment: .leading)]) {
                    ForEach(Array(AllergyDetailView.allergyFoodInfo.enumerated()), id: \.0) { idx, name in
                        Text("\(String(idx + 1)). \(name)")
                            .font(.customFont(forTextStyle: .body))
                            .foregroundColor(env.accountSession.userInfo.data!.allergyinfo.contains(idx + 1) ?
                                .red : .primary)
                    }
                }
            }
            .padding()
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(20)

            if let data = mealData.data {
                VStack(spacing: 15) {
                    ForEach(data.menunames, id: \.menuid) { menu in
                        HStack {
                            if let menuAllergyData = allergyData[menu.menuid] {
                                Text(menu.menuname)
                                    .font(.customFont(forTextStyle: .body))
                                    .foregroundColor(menuAllergyData.count == 0 ?
                                        .primary : .red)
                                Spacer()
                                Text(menuAllergyData.map({ AllergyDetailView.allergyFoodInfo[$0 - 1] })
                                    .joined(separator: ", ") + " 함유")
                                .font(.customFont(forTextStyle: .body))
                            } else {
                                Text(menu.menuname)
                                    .font(.customFont(forTextStyle: .body))
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(20)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: 480)
        .navigationTitle("알러지 정보")
    }
}
