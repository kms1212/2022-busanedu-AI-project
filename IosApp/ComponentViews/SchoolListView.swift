//
//  SchoolListView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/06.
//

import SwiftUI

struct SchoolListView: View {
    @Binding var keyword: String
    @Binding var selected: School.ResponseStruct.SchoolDataStruct?

    @State var currentPage: Int = 1
    @State var maxPage: Int = 1
    @State var schoolData = School()

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    currentPage -= 1
                }, label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.primary)
                        .font(.caption)
                })
                .frame(width: 50, height: 30)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(10)
                .disabled(currentPage < 2)

                Spacer()

                if schoolData.data != nil {
                    Text("페이지 \(currentPage) / \(maxPage)")
                        .font(.customFont(forTextStyle: .body))
                }

                Spacer()

                Button(action: {
                    currentPage += 1
                }, label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.primary)
                        .font(.caption)
                })
                .frame(width: 50, height: 30)
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(10)
                .disabled(currentPage > maxPage - 1)
            }
            .padding([.top, .horizontal])
            ScrollView {
                if let data = schoolData.data {
                    VStack {
                        ForEach(data.data) { rowElem in
                            Button(action: {
                                selected = rowElem
                            }, label: {
                                HStack {
                                    VStack {
                                        HStack {
                                            Text(rowElem.school_name)
                                                .font(.customFont(forTextStyle: .title3))
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                        HStack {
                                            Text(rowElem.location)
                                                .font(.customFont(forTextStyle: .caption))
                                                .multilineTextAlignment(.leading)
                                            Spacer()
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.primary)
                            })

                            if rowElem != data.data.last! {
                                Divider()
                            }
                        }
                    }
                    .padding()
                } else {
                    ProgressView()
                }
            }
        }
        .onAppear {
            updateSchoolList()
        }
        .onChange(of: keyword) { _ in
            currentPage = 1

            updateSchoolList()
        }
        .onChange(of: currentPage) { _ in
            updateSchoolList()
        }
        .background(Color(uiColor: .systemGray5))
        .cornerRadius(15)
    }

    func updateSchoolList() {
        School.getSchoolInfoByName(schoolName: keyword, page: currentPage, pageSize: 10) { result in
            switch result {
            case .success(let data):
                schoolData = data
                let itemCount = data.data!.count
                maxPage = Int(itemCount / 10)
                if itemCount - maxPage * 10 > 0 {
                    maxPage += 1
                }

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
