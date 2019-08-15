//
//  ImageSaveService.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class ImageStorageService {
    
    static func saveImage(name: String, image: UIImage) -> String? {
        guard let data = image.pngData(),
            let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        do {
            let filePath = directory.appendingPathComponent("\(name).png")
            try data.write(to: filePath)
            return filePath.absoluteString
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func getSavedImage(name: String, onComplete: @escaping (UIImage?) -> Void) {
        let mySerialQueue = DispatchQueue(label: "ru.vsu.MyGarden", qos: .background)
        mySerialQueue.async {
            guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
                onComplete(nil)
                return
            }
            onComplete(UIImage(contentsOfFile: URL(fileURLWithPath: directory.absoluteString).appendingPathComponent("\(name).png").path))
        }
    }
}
