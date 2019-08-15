//
//  PlantDetailImageCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class PlantDetailImageCell: UITableViewCell {
    
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    func configureCell(image: UIImage?) {
        plantImageView.image = image
    }
    
    func handleScroll(offset: CGFloat) {
        clipsToBounds = offset >= 0
        heightConstraint.constant = 300 - offset
    }
}
