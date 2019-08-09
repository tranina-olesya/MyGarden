//
//  PlantDetailViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 09/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var wateringTimeLabel: UILabel!
    
    @IBOutlet weak var dayPottedLabel: UILabel!
    
    var plant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = plant?.name
        descriptionLabel.text = plant?.descriptionText
        wateringTimeLabel.text = plant?.wateringTime.rawValue
        if let dayPotted = plant?.dayPotted {
            dayPottedLabel.text = DateConvertHelper.convertToString(date: dayPotted)
        }
    }
    
}
