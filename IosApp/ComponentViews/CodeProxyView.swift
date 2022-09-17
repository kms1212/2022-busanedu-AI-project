//
//  CodeProxyView.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/15.
//

import SwiftUI

struct CodeProxyView: View {
    let action: () -> Void

    var body: some View {
        Text("")
            .onAppear(perform: action)
    }
}
