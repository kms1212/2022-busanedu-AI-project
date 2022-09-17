//
//  PhotoMatchView.swift
//  iosApp
//
//  Created by 권민수 on 2022/07/05.
//

import SwiftUI

struct PhotoMatchView: View {
    @EnvironmentObject var env: AppEnvironment

    @StateObject var viewModel = PhotoMatchViewModel()

    @Binding var sharedData: CameraTabView.SharedData

    @State var isDragging = false
    @State var imageScaleRatio: CGFloat?

    var drag: some Gesture {
        DragGesture()
            .onChanged { val in
                isDragging = true
                if let imageScaleRatio = imageScaleRatio {
                    let startPosX = min(val.startLocation.x, val.location.x) / imageScaleRatio
                    let startPosY = min(val.startLocation.y, val.location.y) / imageScaleRatio
                    let endPosX = max(val.startLocation.x, val.location.x) / imageScaleRatio
                    let endPosY = max(val.startLocation.y, val.location.y) / imageScaleRatio

                    if let selectedImageIndex =  viewModel.selectedImageIndex {
                        let oldData = sharedData.inferenceData[selectedImageIndex]
                        sharedData.inferenceData[selectedImageIndex] =
                            Inference.ResponseStruct(id: oldData.id,
                                                     class_num: oldData.class_num,
                                                     xpos: Int(startPosX),
                                                     ypos: Int(startPosY),
                                                     width: Int(endPosX - startPosX),
                                                     height: Int(endPosY - startPosY))
                    }
                }
            }
            .onEnded { _ in
                isDragging = false
                viewModel.cropImages(sharedData: sharedData)
            }
    }

    var body: some View {
        VStack(spacing: 15) {
            Spacer()
                .frame(height: 30)
            ScrollView(.horizontal) {
                HStack(spacing: 10) {
                    Spacer().frame(width: 0)
                    ForEach(Array(viewModel.croppedImageList.enumerated()), id: \.element) { index, content in
                        VStack {
                            Button(action: {
                                viewModel.selectedImageIndex = index
                            }, label: {
                                if viewModel.selectedImageIndex == index {
                                    Image(uiImage: content.image)
                                        .resizable()
                                        .border(Color.accentColor, width: 2)
                                        .scaledToFit()
                                } else {
                                    Image(uiImage: content.image)
                                        .resizable()
                                        .scaledToFit()
                                }
                            })
                            if let menuIndex = content.menuIndex {
                                Text(viewModel.mealMenuList[menuIndex].menuData.menuname_filtered)
                                    .font(.customFont(forTextStyle: .body))
                            }
                        }
                    }
                    Spacer().frame(width: 0)
                }
            }
            .padding([.top, .bottom], 10)
            .frame(height: 120)
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(20)
            HStack {
                if viewModel.selectedImageIndex != nil {
                    Picker("", selection: $viewModel.pickerSelection) {
                        Text("해당하는 메뉴를 선택하세요.")
                            .font(.customFont(forTextStyle: .body))
                            .id(-1)
                        ForEach(Array(viewModel.mealMenuList.enumerated()), id: \.offset) { index, menu in
                            Text(menu.menuData.menuname_filtered)
                                .font(.customFont(forTextStyle: .body))
                                .id(index)
                        }
                    }
                    .id(viewModel.pickerUpdate)
                    .foregroundColor(.primary)
                    .pickerStyle(MenuPickerStyle())
                    .padding([.horizontal], 15)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(10)
                }
                Spacer()
                Button(action: {
                    viewModel.addInferenceData(sharedData: $sharedData)
                    viewModel.cropImages(sharedData: sharedData)
                    viewModel.selectedImageIndex = sharedData.inferenceData.count - 1
                }, label: {
                    Image(systemName: "plus")
                })
                Button(action: {
                    viewModel.removeInfrerenceData(sharedData: $sharedData, index: viewModel.selectedImageIndex!)
                    viewModel.cropImages(sharedData: sharedData)
                }, label: {
                    Image(systemName: "trash")
                })
                .disabled(viewModel.selectedImageIndex == nil)
            }
            VStack {
                GeometryReader { geo in
                    Canvas { context, size in
                        let bgImage = context.resolve(Image(uiImage: sharedData.originalImage).resizable())
                        context.draw(bgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

                        for (index, obj) in sharedData.inferenceData.enumerated() {
                            if let imageScaleRatio = imageScaleRatio {
                                if viewModel.selectedImageIndex == index {
                                    context.stroke(Path(
                                        CGRect(x: CGFloat(obj.xpos) * imageScaleRatio,
                                           y: CGFloat(obj.ypos) * imageScaleRatio,
                                           width: CGFloat(obj.width) * imageScaleRatio,
                                           height: CGFloat(obj.height) * imageScaleRatio)),
                                                   with: .color(.blue))
                                } else {
                                    context.stroke(Path(
                                        CGRect(x: CGFloat(obj.xpos) * imageScaleRatio,
                                           y: CGFloat(obj.ypos) * imageScaleRatio,
                                           width: CGFloat(obj.width) * imageScaleRatio,
                                           height: CGFloat(obj.height) * imageScaleRatio)),
                                               with: .color(.gray))
                                }
                            }
                        }
                    }
                    .aspectRatio(sharedData.originalImage.size.width / sharedData.originalImage.size.height,
                                 contentMode: .fit)
                    .gesture(drag)
                    .onAppear {
                        imageScaleRatio = geo.size.width / sharedData.originalImage.size.width
                    }
                }
            }
            Spacer()
            Button(action: {
                viewModel.sendInferenceData(env: env, sharedData: sharedData)
            }, label: {
                Circle()
                    .foregroundColor(.accentColor)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color(uiColor: .systemGray6))
                    }
            })
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.refreshViewModel(sharedData: sharedData, env: env)
        }
    }
}
