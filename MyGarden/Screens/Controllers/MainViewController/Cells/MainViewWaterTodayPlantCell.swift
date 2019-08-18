//
//  MainViewWaterTodayPlantCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class MainViewWaterTodayPlantCell: UICollectionViewCell {
    private struct Constants {
        static let imageWidth: CGFloat = 200.0
    }
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var daysLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var wateredView: UIView!
    
    lazy var dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
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
    
    var wasSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        wateredView.isHidden = true
    }
    
    private func getDaysFromLastWatered() -> Int? {
        guard let shouldWatered = plant?.nextWateringTime else {
            return nil
        }
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: shouldWatered)
        let date2 = calendar.startOfDay(for: Date(timeIntervalSinceNow: 60 * 60 * 24))
    
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day
    }
    
    func loadImage() {
        guard let name = plant?.name else {
            return
        }
        ImageStorageService.getSavedImage(name: name) { (image) in
            let resizedImage = image?.resize(width: Constants.imageWidth)
            
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
        guard let plant = plant,
            !wasSelected else {
            return
        }
        
        wateredView.isHidden = false
        daysLabel.isHidden = true
        wasSelected = true
        
        plant.lastWatered = Date()
        plant.nextWateringTime = UserNotificationService.getNextWateringTime(plant: plant)
        dataProvider.savePlant(plant: plant)
        UserNotificationService.updateNotification(plant: plant)
    }
}
