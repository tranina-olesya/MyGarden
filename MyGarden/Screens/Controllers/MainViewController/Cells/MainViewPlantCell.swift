//
//  MainViewPlantCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 08/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class MainViewPlantCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    private struct Constants {
        static let imageWidth: CGFloat = 400.0
    }
    
    var plant: Plant? {
        didSet {
            nameLabel.text = plant?.name
            loadImage()
        }
    }
    
    func loadImage() {
        guard let name = plant?.name else {
            return
        }
        ImageStorageService.getSavedImage(name: name) { (image) in
            let resizedImage = image?.resize(width: Constants.imageWidth)
            
            DispatchQueue.main.async {
                if resizedImage != nil {
                    self.imageView.image = resizedImage
                } else {
                    self.imageView.image = image
                }
            }
        }
    }
}
