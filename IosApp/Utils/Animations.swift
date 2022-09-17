//
//  Animations.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/28.
//

import Foundation
import SwiftUI

extension AnyTransition {
    static var slideTrailing: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    }

    static var slideLeading: AnyTransition {
        AnyTransition.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
    }
}
