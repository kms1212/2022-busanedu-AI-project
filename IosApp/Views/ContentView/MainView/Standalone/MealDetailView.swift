//
//  MealDetailView.swift
//  IosApp
//
//  Created by 권민수 on 2022/09/10.
//

import SwiftUI

struct MealDetailView: View {
    enum FocusField: Hashable {
        case comment
    }

    @EnvironmentObject var env: AppEnvironment

    @StateObject var viewModel = MealDetailViewModel()

    @State var imageScaleRatio: CGFloat?
    @State var commentText = ""
    @State var showComments = false

    @FocusState public var focusedField: MealDetailView.FocusField?

    var mealid: Int

    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.mealData {
            case .success(let mealData):
                ScrollView {
                    VStack(spacing: 15) {
                        VStack {
                            switch viewModel.inferenceList {
                            case .success(let inferences):
                                if inferences.count > 0 {
                                    TabView {
                                        ForEach(inferences, id: \.data!.inferenceid) { inference in
                                            if let image = inference.data?.mealimage {
                                                GeometryReader { geo in
                                                    Canvas { context, size in
                                                        let bgImage = context.resolve(Image(uiImage: image)
                                                            .resizable())
                                                        context.draw(bgImage, in: CGRect(x: 0, y: 0,
                                                                                         width: size.width,
                                                                                         height: size.height))

                                                        for obj in inference.data!.jsondata {
                                                            if let imageScaleRatio = imageScaleRatio {
                                                                context.stroke(Path(
                                                                    CGRect(x: CGFloat(obj.xpos) * imageScaleRatio,
                                                                       y: CGFloat(obj.ypos) * imageScaleRatio,
                                                                       width: CGFloat(obj.width) * imageScaleRatio,
                                                                       height: CGFloat(obj.height) * imageScaleRatio)),
                                                                               with: .color(.blue))

                                                                context.fill(Path(
                                                                    CGRect(x: CGFloat(obj.xpos) * imageScaleRatio,
                                                                       y: CGFloat(obj.ypos) * imageScaleRatio,
                                                                       width: CGFloat(obj.width) * imageScaleRatio,
                                                                       height: 15)),
                                                                               with: .color(.blue))

                                                                for menu in mealData.data!.menunames
                                                                where menu.menuid == obj.menuid {
                                                                    let text = context.resolve(
                                                                        Text(menu.menuname_filtered)
                                                                        .font(.customFont(forTextStyle: .caption))
                                                                        .foregroundColor(.white))

                                                                    context.draw(text,
                                                                                 at: CGPoint(x: CGFloat(obj.xpos + 3)
                                                                                                * imageScaleRatio,
                                                                                             y: CGFloat(obj.ypos + 3)
                                                                                                * imageScaleRatio),
                                                                                 anchor: .topLeading)
                                                                }
                                                            }
                                                        }
                                                    }
                                                    .aspectRatio(image.size.width / image.size.height,
                                                                 contentMode: .fit)
                                                    .onAppear {
                                                        imageScaleRatio = geo.size.width / image.size.width
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .tabViewStyle(PageTabViewStyle())
                                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                                    .aspectRatio(4 / 3, contentMode: .fit)
                                    .background(Color(uiColor: .systemGray6))
                                    .cornerRadius(20)
                                } else {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text("식단 이미지가 없습니다.")
                                                .font(.customFont(forTextStyle: .title2))
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .aspectRatio(4 / 3, contentMode: .fit)
                                    .background(Color(uiColor: .systemGray6))
                                    .cornerRadius(20)
                                }
                            case .failure:
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Text("식단 이미지가 없습니다.")
                                            .font(.customFont(forTextStyle: .title2))
                                        Spacer()
                                    }
                                    Spacer()
                                }
                                .aspectRatio(4 / 3, contentMode: .fit)
                                .background(Color(uiColor: .systemGray6))
                                .cornerRadius(20)
                            case .loading:
                                VStack {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            ProgressView()
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .aspectRatio(4 / 3, contentMode: .fit)
                                    .background(Color(uiColor: .systemGray6))
                                    .cornerRadius(20)
                                }
                            case .waiting:
                                CodeProxyView {
                                    viewModel.refreshInferenceList(mealid: mealid)
                                }
                            }
                        }

                        VStack {
                            switch viewModel.schoolInfo {
                            case .success(let schoolInfo):
                                VStack(spacing: 15) {
                                    HStack {
                                        Text(schoolInfo.data!.data[0].school_name)
                                            .font(.customFont(forTextStyle: .headline))
                                        Spacer()
                                        Text("\(mealData.data!.mealdate) \(Meal.mealTimeDict[mealData.data!.mealtime])")
                                            .font(.customFont(forTextStyle: .headline))
                                    }
                                    .navigationBarTitle(schoolInfo.data!.data[0].school_name + " " +
                                                        mealData.data!.mealdate + " " +
                                                        Meal.mealTimeDict[mealData.data!.mealtime])
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(mealData.data!.menunames, id: \.menuid) { menu in
                                                HStack {
                                                    switch viewModel.allergyData {
                                                    case .success(let allergyData):
                                                        if let menuAllergyData = allergyData[menu.menuid] {
                                                            Text(menu.menuname_filtered)
                                                                .font(.customFont(forTextStyle: .body))
                                                                .foregroundColor(menuAllergyData.count == 0 ?
                                                                    .primary : .red)
                                                        } else {
                                                            Text(menu.menuname_filtered)
                                                                .font(.customFont(forTextStyle: .body))
                                                        }
                                                    case .failure:
                                                        Text(menu.menuname_filtered)
                                                            .font(.customFont(forTextStyle: .body))
                                                    default:
                                                        EmptyView()
                                                    }
                                                }
                                            }
                                        }
                                        Spacer()
                                        Button(action: {
                                            viewModel.autolike()
                                        }, label: {
                                            switch viewModel.likeStatus {
                                            case .success(let likeStatus):
                                                HStack {
                                                    Image(systemName: "hand.thumbsup.fill")
                                                    switch viewModel.likeCount {
                                                    case .success(let likeCount):
                                                        Text(String(likeCount))
                                                            .font(.customFont(forTextStyle: .body))
                                                    default:
                                                        EmptyView()
                                                    }
                                                }
                                                .foregroundColor(likeStatus == true ? .accentColor : .primary)
                                            case .waiting:
                                                CodeProxyView {
                                                    viewModel.refreshLikeStatus(mealid: mealid)
                                                }
                                            default:
                                                EmptyView()
                                            }
                                        })
                                    }
                                    if let allergyData = viewModel.allergyData.getData {
                                        HStack {
                                            Spacer()
                                            NavigationLink(destination:
                                                            AllergyDetailView(mealData: mealData,
                                                                              allergyData: allergyData)
                                                                .environmentObject(env)) {
                                                Text("알러지 정보")
                                                    .font(.customFont(forTextStyle: .body))
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(uiColor: .systemGray6))
                                .cornerRadius(20)
                                Spacer()
                            case .waiting:
                                CodeProxyView {
                                    viewModel.refreshSchoolInfo(schoolcode1: mealData.data!.schoolcode1,
                                                                schoolcode2: mealData.data!.schoolcode2)
                                }
                            default:
                                EmptyView()
                            }
                        }
                    }
                    .padding()
                }

                VStack(alignment: .leading) {
                    switch viewModel.commentList {
                    case .success(let comments):
                        HStack {
                            Text("댓글")
                                .font(.customFont(forTextStyle: .headline).bold())
                            Spacer()
                            Text("\(comments.count)개")
                                .font(.customFont(forTextStyle: .headline))
                            if comments.count > 1 {
                                Button(action: {
                                    withAnimation {
                                        showComments = !showComments
                                    }
                                }, label: {
                                    if showComments {
                                        Image(systemName: "xmark")
                                    } else {
                                        Text("더보기")
                                            .font(.customFont(forTextStyle: .callout))
                                    }
                                })
                            }
                        }
                        if showComments {
                            ForEach(comments, id: \.data!.commentid) { comment in
                                VStack(alignment: .leading) {
                                    Text(comment.data!.user)
                                        .font(.customFont(forTextStyle: .body))
                                    Text(comment.data!.comment)
                                        .font(.customFont(forTextStyle: .body))
                                    Spacer()
                                }
                                .frame(height: 50)
                                Divider()
                            }
                        } else {
                            if comments.count != 0 {
                                VStack(alignment: .leading) {
                                    Text(comments[0].data!.user)
                                        .font(.customFont(forTextStyle: .body))
                                    Text(comments[0].data!.comment)
                                        .font(.customFont(forTextStyle: .body))
                                    Spacer()
                                }
                                .frame(height: 50)
                            }
                        }
                    case .waiting:
                        CodeProxyView {
                            viewModel.refreshCommentList(mealid: mealid)
                        }
                    default:
                        EmptyView()
                    }

                    HStack(spacing: 10) {
                        TextField("댓글 추가", text: $commentText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .onTapGesture {
                                focusedField = .comment
                            }
                        Button(action: {
                            if commentText != "" {
                                viewModel.addComment(comment: commentText)
                                commentText = ""
                                UIApplication.shared.endEditing()
                            }
                        }, label: {
                            Image(systemName: "paperplane.fill")
                        })
                    }

                    Spacer()
                        .frame(height: 20)
                }
                .padding()
                .background(Color(uiColor: .systemGray6))
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(radius: 5)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        HStack(spacing: 10) {
                            TextField("댓글 추가", text: $commentText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .comment)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                    UIApplication.shared.endEditing()
                                }
                            Button(action: {
                                if commentText != "" {
                                    viewModel.addComment(comment: commentText)
                                    commentText = ""
                                    UIApplication.shared.endEditing()
                                }
                            }, label: {
                                Image(systemName: "paperplane.fill")
                            })
                        }
                    }
                }
            case .waiting:
                CodeProxyView {
                    viewModel.refreshMealDataAndAllergyData(mealid: mealid,
                                                            userAllergyInfo: env.accountSession
                        .userInfo.data!.allergyinfo)
                }
            default:
                EmptyView()
            }
        }
        .frame(maxWidth: 480)
        .ignoresSafeArea(.all, edges: [.bottom])
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Shared.viewMessageExchanger.sendMessageTo(viewId: .mainView, message: [
                "showTabBar": false
            ])
        }
    }
}
