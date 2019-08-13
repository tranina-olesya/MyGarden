//
//  WateringTimePickerCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class WateringTimePickerCell: UITableViewCell {
    @IBOutlet weak var wateringTimeTextField: UITextField!
    
    private var wateringTimePicker: UIPickerView?
    
    private let wateringTimeValues: [String] = {
        var values = [String]()
        for enumValue in WateringTime.allCases {
            values.append(enumValue.rawValue)
        }
        return values
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        wateringTimePicker = UIPickerView()
        wateringTimePicker?.dataSource = self
        wateringTimePicker?.delegate = self
        wateringTimeTextField.inputView = wateringTimePicker
    }
}

extension WateringTimePickerCell: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return wateringTimeValues.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return wateringTimeValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        wateringTimeTextField.text = wateringTimeValues[row]
    }
}
