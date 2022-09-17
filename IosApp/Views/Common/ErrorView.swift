//
//  ErrorView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/26.
//
import SwiftUI
struct ErrorView: View {
    var body: some View {
        Text("Error")
            .font(.customFont(forTextStyle: .body))
    }
}
struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
