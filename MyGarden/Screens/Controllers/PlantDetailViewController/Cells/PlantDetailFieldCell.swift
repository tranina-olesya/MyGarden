//
//  PlantFieldCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class PlantDetailFieldCell: UITableViewCell {
    @IBOutlet weak var fieldNameLabel: UILabel!
    
    @IBOutlet weak var fieldValueLabel: UILabel!
    
    func configureCell(fieldName: String, fieldValue: String) {
        fieldNameLabel.text = fieldName
        fieldValueLabel.text = fieldValue
    }
}
