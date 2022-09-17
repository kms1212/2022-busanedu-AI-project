//
//  UserData.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/28.
//

import Foundation
import SwiftUI

struct UserData: ObservableObject {
    let username: String
    let profileImage: Image
    let usertype: UserType
    let isAdministrator: Bool

    init (username: String, profileImage: Image, usertype: UserType, isAdministrator: Bool) {
        self.username = username
        self.profileImage = profileImage
        self.usertype = usertype
        self.isAdministrator = isAdministrator
    }

    enum UserType {
        case student, general
    }
}
