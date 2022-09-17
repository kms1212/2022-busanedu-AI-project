//
//  ViewExtension.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/06.
//

import SwiftUI

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private struct UIKitAppear: UIViewControllerRepresentable {
    let action: () -> Void

    func makeUIViewController(context: Context) -> Controller {
        Controller(action)
    }

    func updateUIViewController(_ controller: Controller, context: Context) {}

    class Controller: UIViewController {
        let action: () -> Void

        init(_ action: @escaping () -> Void) {
            self.action = action
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() { }

        override func viewDidAppear(_ animated: Bool) {
            action()
        }
    }
}

extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }

    public func onUIKitAppear(perform action: @escaping () -> Void) -> some View {
        self.overlay(UIKitAppear(action: action).disabled(true))
    }
}
