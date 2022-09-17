//
//  ProfileImageView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/03.
//

import SwiftUI

struct ProfileImageView: View {
    var image: UIImage?

    private var borderColor: Color = Color(uiColor: .systemGray4)
    private var borderWidth: CGFloat = 3

    @inlinable public func border(width: CGFloat? = nil, color: Color? = nil) -> Self {
        var copy = self
        if let width = width { copy.borderWidth = width }
        if let color = color { copy.borderColor = color }
        return copy
    }

    init(image: UIImage?) {
        self.image = image
    }

    var body: some View {
        GeometryReader { geo in
            Circle()
                .foregroundColor(Color(uiColor: .systemGray4))
                .frame(width: geo.size.width, height: geo.size.height)
                .overlay(
                    Image(uiImage: image ?? UIImage(named: "ProfileImagePlaceholder")!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width - borderWidth * 2, height: geo.size.height - borderWidth * 2)
                        .background(.background)
                        .cornerRadius(max(geo.size.width, geo.size.height))
                )
        }
    }
}
