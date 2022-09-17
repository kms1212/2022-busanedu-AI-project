//
//  PersonalDataView.swift
//  iosApp
//
//  Created by 권민수 on 2022/06/05.
//

import SwiftUI
import Navajo_Swift

struct PersonalDataView: View {
    @EnvironmentObject var env: AppEnvironment

    @Binding var userData: DetailedUserProfile?

    @State var userType: String = "USER_STUDENT"
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var birthDate: Date = Date()
    @State var schoolSearch: String = ""
    @State var studentGrade: String = ""
    @State var studentClass: String = ""
    @State var studentPid: String = ""
    @State var selectedSchoolInfo: School.ResponseStruct.SchoolDataStruct?
    @State var showSchoolSearchControl: Bool = false

    var body: some View {
        VStack {
            VStack {
                Picker("User type selection", selection: $userType) {
                    Text("학생")
                        .font(.customFont(forTextStyle: .body))
                        .tag("USER_STUDENT")
                }
                .pickerStyle(.segmented)
                .padding(5)

                if userType != "" {
                    if userType == "USER_STUDENT" {
                        VStack {
                            HStack {
                                TextField("이름", text: $firstName)
                                    .textContentType(.givenName)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .padding(5)
                                    .textFieldStyle(.roundedBorder)
                                TextField("성", text: $lastName)
                                    .textContentType(.familyName)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .padding(5)
                                    .textFieldStyle(.roundedBorder)
                            }
                            DatePicker(
                              "생년월일",
                              selection: $birthDate,
                              displayedComponents: [.date]
                            )
                            .pickerStyle(.wheel)

                            VStack {
                                HStack {
                                    Text("학교명")
                                        .font(.customFont(forTextStyle: .body))
                                    Spacer(minLength: 30)
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(Color(uiColor: .systemGray5))
                                        .overlay(
                                            Text(selectedSchoolInfo?.school_name ?? "")
                                                .font(.customFont(forTextStyle: .body))
                                        )
                                        .frame(height: 35)
                                        .onTapGesture {
                                            showSchoolSearchControl = true
                                            selectedSchoolInfo = nil
                                        }
                                }

                                if showSchoolSearchControl {
                                    TextField("학교 검색", text: $schoolSearch)
                                        .textFieldStyle(.roundedBorder)
                                    SchoolListView(keyword: $schoolSearch, selected: $selectedSchoolInfo)
                                        .onChange(of: selectedSchoolInfo) { _ in
                                            showSchoolSearchControl = false
                                        }
                                }
                            }

                            HStack {
                                TextField("학년", text: $studentGrade)
                                    .keyboardType(.numberPad)
                                    .padding(5)
                                    .textFieldStyle(.roundedBorder)
                                TextField("반", text: $studentClass)
                                    .keyboardType(.numberPad)
                                    .padding(5)
                                    .textFieldStyle(.roundedBorder)
                                TextField("번호", text: $studentPid)
                                    .keyboardType(.numberPad)
                                    .padding(5)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(20)
                        .transition(.slide)
                    } else {
                        ErrorView()
                    }
                }
                Spacer()
            }
            .frame(maxWidth: 320)

            HStack {
                Spacer()
                Button(action: {
                    Shared.viewMessageExchanger.sendMessageTo(viewId: .signUpView, message: [
                        "changeView": ViewMessageExchanger.ViewEnum.emailVerificationView
                    ])
                }, label: {
                    Text("다음")
                        .font(.customFont(forTextStyle: .body))
                })
            }
            .padding()
        }
        .padding()
    }
}
