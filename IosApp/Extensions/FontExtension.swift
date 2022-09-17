//
//  FontExtension.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/02.
//

import SwiftUI

extension Font {
    init(_ uiFont: UIFont) {
      self = Font(uiFont as CTFont)
    }

    static let fonts: [Font.TextStyle: Font] = [
        .largeTitle: .custom("Apple SD Gothic Neo", size: 30.6, relativeTo: .largeTitle),
        .title: .custom("Apple SD Gothic Neo", size: 25.2, relativeTo: .title),
        .title2: .custom("Apple SD Gothic Neo", size: 19.8, relativeTo: .title2),
        .title3: .custom("Apple SD Gothic Neo", size: 18, relativeTo: .title3),
        .headline: .custom("Apple SD Gothic Neo", size: 15.3, relativeTo: .headline),
        .body: .custom("Apple SD Gothic Neo", size: 15.3, relativeTo: .body),
        .callout: .custom("Apple SD Gothic Neo", size: 14.4, relativeTo: .callout),
        .subheadline: .custom("Apple SD Gothic Neo", size: 13.5, relativeTo: .subheadline),
        .footnote: .custom("Apple SD Gothic Neo", size: 11.7, relativeTo: .footnote),
        .caption: .custom("Apple SD Gothic Neo", size: 10.8, relativeTo: .caption),
        .caption2: .custom("Apple SD Gothic Neo", size: 9.9, relativeTo: .caption2)
    ]

    static func customFont(forTextStyle style: TextStyle) -> Font {
        return fonts[style]!
    }
}
