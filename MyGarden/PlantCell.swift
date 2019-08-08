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
            //imageView.image =
            nameLabel.text = plant?.name
        }
    }
}
