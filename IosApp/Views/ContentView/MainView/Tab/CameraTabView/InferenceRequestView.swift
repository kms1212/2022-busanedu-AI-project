//
//  InferenceRequestView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/05.
//

import SwiftUI

struct InferenceRequestView: View {
    @EnvironmentObject var env: AppEnvironment

    @StateObject var viewModel = InferenceRequestViewModel()

    @Binding var sharedData: CameraTabView.SharedData

    var body: some View {
        ProgressView()
        .onAppear {
            viewModel.requestInference(env: env, sharedData: _sharedData)
        }
    }
}
