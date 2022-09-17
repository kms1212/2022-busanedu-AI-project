//
//  DownloadImage.swift
//  iosApp
//
//  Created by 권민수 on 2022/08/10.
//

import Foundation
import SwiftUI

func downloadImageSync(url: URL) -> UIImage? {
    return UIImage(data: (try? Data(contentsOf: url))!)
}

func downloadImageAsync(url: URL, _ callback: @escaping (UIImage?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        let data = try? Data(contentsOf: url)

        if let data = data {
            callback(UIImage(data: data))
        } else {
            callback(nil)
        }
    }
}
