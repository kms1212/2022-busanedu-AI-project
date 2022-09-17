//
//  SettingsCategoryListItemView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/03.
//

import SwiftUI

struct SettingsCategoryListItemView: View {
    var destination: AnyView
    var iconContent: AnyView
    var title: String

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                iconContent
                Text(title)
                    .font(.customFont(forTextStyle: .body))
                Spacer()
                Image(systemName: "chevron.right")
            }
            .foregroundColor(.primary)
            .frame(height: 35)
        }
    }
}
