//
//  WaterSchedulePickerCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 13/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class WaterSchedulePickerCell: UITableViewCell {

    @IBOutlet weak var waterScheduleTextField: UITextField!
    
    var waterSchedulePicker: UIPickerView?

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func initUI() {
        waterSchedulePicker = UIPickerView()
        waterSchedulePicker?.dataSource = self
        waterSchedulePicker?.delegate = self
        waterScheduleTextField.inputView = waterSchedulePicker
    }
}

extension WaterSchedulePickerCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return waterScheduleValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return waterScheduleValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        waterScheduleTextField.text = String(row + 1)
    }
}
