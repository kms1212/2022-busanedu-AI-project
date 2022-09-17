//
//  UserDataView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/07.
//

import SwiftUI
import Navajo_Swift

struct UserDataView: View {
    @EnvironmentObject var env: AppEnvironment

    @Binding var userData: DetailedUserProfile?

    @State var userId: String = ""
    @State var userName: String = ""
    @State var userEmail: String = ""
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    @State var isPwValidated: Bool = false
    @State var isPwConfirmed: Bool = false
    @State var userType: String = ""

    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Spacer()
                    VStack {
                        TextField("아이디", text: $userId)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(5)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.asciiCapable)

                        TextField("프로필 이름", text: $userName)
                            .textContentType(.nickname)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(5)
                            .textFieldStyle(.roundedBorder)

                        TextField("이메일", text: $userEmail)
                            .textContentType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(5)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            SecureField("비밀번호", text: $password)
                                .textContentType(.newPassword)
                            if isPwValidated {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(5)
                        .textFieldStyle(.roundedBorder)

                        HStack {
                            SecureField("비밀번호 확인", text: $passwordConfirm)
                                .textContentType(.newPassword)
                            if isPwConfirmed {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                                    .transition(.slide)
                                    .transition(.opacity)
                            }
                        }
                        .padding(5)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: password) { password in
                            let pwrules: [PasswordRule] = [LengthRule(min: 10, max: 64),
                                           RequiredCharacterRule(preset: .decimalDigitCharacter),
                                           RequiredCharacterRule(preset: .lowercaseCharacter),
                                           RequiredCharacterRule(preset: .symbolCharacter)
                            ]

                            let validator = PasswordValidator(rules: pwrules)

                            withAnimation {
                                isPwValidated = validator.validate(password) == nil
                            }
                        }
                        .onChange(of: passwordConfirm) { passwordConfirm in
                            withAnimation {
                                isPwConfirmed = password == passwordConfirm
                            }
                        }
                    }
                    .frame(maxWidth: 320)
                    Spacer()
                }
            }
            HStack {
                Spacer()
                Button(action: {
                    Shared.viewMessageExchanger.sendMessageTo(viewId: .signUpView, message: [
                        "changeView": ViewMessageExchanger.ViewEnum.personalDataView
                    ])
                }, label: {
                    Text("다음")
                })
            }
            .padding()
        }
        .padding()
    }
}
