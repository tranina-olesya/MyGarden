//
//  MainViewWaterTodayPlantCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class MainViewWaterTodayPlantCell: UICollectionViewCell {
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var wateredView: UIView!
    
    var plant: Plant? {
        didSet {
            guard let name = plant?.name,
                let days = getDaysFromLastWatered() else {
                return
            }
            nameLabel.text = name
            daysLabel.text = days < 2 ? "Today" : "\(days) days"
            loadImage()
        }
    }
    
//    var isWatered = false {
//        didSet {
//            wateredView.isHidden = !isWatered
//        }
//    }
//
    override func awakeFromNib() {
        super.awakeFromNib()
        wateredView.isHidden = true
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
    
    func loadImage() {
        guard let name = plant?.name else {
            return
        }
        ImageStorageService.getSavedImage(name: name) { (image) in
            let resizedImage = image?.resize(width: 200)
            
            DispatchQueue.main.async {
                if resizedImage != nil {
                    self.plantImageView.image = resizedImage
                } else {
                    self.plantImageView.image = image
                }
            }
        }
    }
    
    func cellSelected() {
        wateredView.isHidden = false
        daysLabel.isHidden = true
    }
}
