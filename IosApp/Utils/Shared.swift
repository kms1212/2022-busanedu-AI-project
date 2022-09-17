//
//  Shared.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/16.
//

import Foundation
import Alamofire
import SwiftUI

class Shared {
    static var jsonDecoder = JSONDecoder()
    static var jsonEncoder = JSONEncoder()
    static var networkReachabilityManager = NetworkReachabilityManager()
    static var viewMessageExchanger = ViewMessageExchanger()
}
