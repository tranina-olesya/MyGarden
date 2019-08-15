//
//  PlantCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 08/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class PlantCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
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
            let resizedImage = image?.resize(width: 200)
            
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
