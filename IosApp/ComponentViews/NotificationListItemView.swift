//
//  NotificationListItemView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/04.
//

import SwiftUI

struct NotificationListItemView: View {
    var image: UIImage
    var title: String
    var content: String
    var action: (() -> Void)

    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            VStack {
                HStack {
                    Text(title)
                        .font(.customFont(forTextStyle: .title3))
                    Spacer()
                }
                HStack {
                    Text(content)
                        .font(.customFont(forTextStyle: .body))
                    Spacer()
                }
            }
            Button(action: {
            }, label: {
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            })
        }
        .frame(height: 30)
        .padding()
    }
}
