//
//  ImageSaveService.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class ImageSaveService {
    
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
    
    static func getSavedImage(name: String) -> UIImage? {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        return UIImage(contentsOfFile: URL(fileURLWithPath: directory.absoluteString).appendingPathComponent("\(name).png").path)
    }
}
