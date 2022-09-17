//
//  Settings.swift
//  playground
//
//  Created by 권민수 on 2022/01/28.
//

import Foundation

func resetSettings() {
    UserDefaults.standard.set(false, forKey: "isNotFirstLaunch")
    UserDefaults.standard.set("", forKey: "sessionId")
}
