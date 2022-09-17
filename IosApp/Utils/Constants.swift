//
//  Constants.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/29.
//

import UIKit
import SwiftUI

struct Constants {
    static let vsize: CGRect = UIScreen.main.bounds
    static let vmin: CGFloat = min(vsize.width, vsize.height)
    static let vmax: CGFloat = max(vsize.width, vsize.height)

    static let apiurl: String = "https://api.kms1212.kro.kr/"

    static let unavailableGradient: LinearGradient = .init(colors: [Color(uiColor: .systemGray2),
                                                                    Color(uiColor: .systemGray4)],
                                                           startPoint: .bottomTrailing,
                                                           endPoint: .topLeading)
}
