//
//  LoginView.swift
//  iosApp
//
//  Created by 권민수 on 2022/05/27.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var env: AppEnvironment

    @StateObject private var viewModel = LoginViewModel()

    @FocusState public var focusedField: LoginViewModel.FocusField?

    var body: some View {
        VStack {
            Spacer()
            if viewModel.uidpass {
                VStack {
                    ProfileImageView(image: viewModel.profile.profileImage)
                        .border(width: 3)
                        .frame(width: 80, height: 80)
                    Text(viewModel.profile.data!.username)
                        .font(.customFont(forTextStyle: .body))
                    Spacer()
                        .frame(height: 30)
                }
                .animation(.easeInOut, value: viewModel.uidpass)
            }
            HStack {
                Image(systemName: "person.fill")
                TextField("ID", text: $viewModel.userid)
                    .onChange(of: viewModel.userid) { userid in
                        withAnimation {
                            if viewModel.uidpass {
                                viewModel.uidpass.toggle()
                            }
                            viewModel.showsignup = userid == ""
                            viewModel.uidfail = false
                            viewModel.pwfail = false
                        }
                    }
                    .onAppear {
                        viewModel.focusedField = .id
                    }
                    .textContentType(.username)
                    .focused($focusedField, equals: .id)
                    .textFieldStyle(.roundedBorder)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.asciiCapable)
                if viewModel.uidpass {
                    Button(action: {
                        viewModel.requestLogin(env: env)
                    }, label: {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.primary)
                    })
                } else {
                    Button(action: {
                        viewModel.updateUserProfile()
                    }, label: {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.primary)
                    })
                }
            }

            if viewModel.uidfail {
                Text("ID를 찾을 수 없습니다.")
                    .font(.customFont(forTextStyle: .body))
                    .foregroundColor(.red)
            }

            if viewModel.uidpass {
                HStack {
                    Image(systemName: "key.fill")
                    SecureField("비밀번호", text: $viewModel.password)
                        .focused($focusedField, equals: .password)
                        .textContentType(.password)
                        .textFieldStyle(.roundedBorder)
                }
                .animation(.easeInOut, value: viewModel.uidpass)
            }

            if viewModel.pwfail {
                Text("비밀번호가 올바르지 않습니다.")
                    .font(.customFont(forTextStyle: .body))
                    .foregroundColor(.red)
            }

            Spacer()

            if viewModel.showsignup {
                HStack {
                    Button(action: {
                        viewModel.showmodal = true
                    }, label: {
                        Text("Sign in")
                            .font(.customFont(forTextStyle: .body))
                    })
                    .sheet(isPresented: $viewModel.showmodal) {
                        SignUpView(onDismiss: { viewModel.showmodal = false }).environmentObject(env)
                    }
                }
            }
            Spacer()
                .frame(height: 20)
        }
        .frame(width: 250)
        .onChange(of: viewModel.focusedField) { focusedField in
            self.focusedField = focusedField
        }
        .onAppear {
        }
    }
}
