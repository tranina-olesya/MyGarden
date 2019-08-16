//
//  EditPlantDeleteCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 16/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class EditPlantDeleteCell: UITableViewCell {
    
    weak var delegate: EditPlantDeleteCellDelegate?
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate?.didPressDeleteButton()
    }
}

protocol EditPlantDeleteCellDelegate: class {
    func didPressDeleteButton()
}
