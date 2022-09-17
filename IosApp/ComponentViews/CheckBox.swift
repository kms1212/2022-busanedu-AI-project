//
//  CheckBox.swift
//  iosApp
//
//  Created by 권민수 on 2022/06/04.
//

import SwiftUI

struct CheckBox<Content: View>: View {
    @Binding var isChecked: Bool

    var content: Content

    init(isChecked: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self._isChecked = isChecked
        self.content = content()
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isChecked ? Color(UIColor.systemBlue) : Color.secondary)
            content
        }
        .onTapGesture {
            self.isChecked.toggle()
        }
    }
}
