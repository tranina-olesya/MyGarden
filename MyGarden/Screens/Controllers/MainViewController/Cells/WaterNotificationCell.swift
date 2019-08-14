//
//  WaterNotificationCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class WaterNotificationCell: UICollectionViewCell {
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    var plant: Plant? {
        didSet {
            guard let name = plant?.name,
                let days = getDaysFromLastWatered() else {
                return
            }
            nameLabel.text = name
            daysLabel.text = days < 2 ? "Today" : "\(days) days"
            plantImageView.image = ImageSaveService.getSavedImage(name: name)
        }
    }
    
    private func getDaysFromLastWatered() -> Int? {
        guard let lastWatered = plant?.lastWatered else {
            return nil
        }
        let calendar = Calendar(identifier: .gregorian)
        let date1 = calendar.startOfDay(for: lastWatered)
        let date2 = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day
    }
}
