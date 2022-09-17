//
//  UIImageExtension.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/10.
//

import Foundation
import SwiftUI

extension UIImage {
    func resizeCI(width: CGFloat) -> UIImage? {
        let scale = (Double)(width) / (Double)(self.size.width)
        let image = CIImage(data: self.pngData()!)

        let filter = CIFilter(name: "CILanczosScaleTransform")!
        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(NSNumber(value: scale), forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
        // swiftlint:disable force_cast
        let outputImage = filter.value(forKey: kCIOutputImageKey) as! CIImage
        // swiftlint:enable force_cast

        let context = CIContext(options: [.useSoftwareRenderer: false])
        var resizedImage: UIImage?

        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            resizedImage = UIImage(cgImage: cgImage)
        }
        return resizedImage
    }
}
