//
//  UIApplicationExtension.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/10.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
