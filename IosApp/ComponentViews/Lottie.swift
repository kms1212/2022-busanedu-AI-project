//
//  Lottie.swift
//  playground
//
//  Created by 권민수 on 2022/01/27.
//

import Lottie
import SwiftUI
import UIKit

struct Lottie: UIViewRepresentable {
    var filename: String
    var loopMode: LottieLoopMode = .playOnce
    var animationView = AnimationView()

    func makeUIView(context: UIViewRepresentableContext<Lottie>) -> UIView {
        let view = UIView(frame: .zero)
        animationView.animation = Animation.named(filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.backgroundBehavior = .pauseAndRestore

        animationView.play()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<Lottie>) {

    }
}
