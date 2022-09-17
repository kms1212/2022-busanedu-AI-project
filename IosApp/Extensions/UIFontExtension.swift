//
//  UIFontExtension.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/02.
//

import UIKit

extension UIFont {
    static let fonts: [UIFont.TextStyle: UIFont] = [
        .largeTitle: UIFont.preferredFont(forTextStyle: .largeTitle).withSize(30.6),
        .title1: UIFont.preferredFont(forTextStyle: .title1).withSize(25.2),
        .title2: UIFont.preferredFont(forTextStyle: .title2).withSize(19.8),
        .title3: UIFont.preferredFont(forTextStyle: .title3).withSize(18),
        .headline: UIFont.preferredFont(forTextStyle: .headline).withSize(15.3),
        .body: UIFont.preferredFont(forTextStyle: .body).withSize(15.3),
        .callout: UIFont.preferredFont(forTextStyle: .callout).withSize(14.4),
        .subheadline: UIFont.preferredFont(forTextStyle: .subheadline).withSize(13.5),
        .footnote: UIFont.preferredFont(forTextStyle: .footnote).withSize(11.7),
        .caption1: UIFont.preferredFont(forTextStyle: .caption1).withSize(10.8),
        .caption2: UIFont.preferredFont(forTextStyle: .caption2).withSize(9.9)
    ]

    static func customFont(forTextStyle style: UIFont.TextStyle) -> UIFont {
        let customFont = fonts[style]!
        let metrics = UIFontMetrics(forTextStyle: style)
        let scaledFont = metrics.scaledFont(for: customFont)

        return scaledFont
    }
}
