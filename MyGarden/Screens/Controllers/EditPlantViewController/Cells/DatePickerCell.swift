//
//  DatePickerCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class DatePickerCell: UITableViewCell {
    @IBOutlet weak var dayPottedTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    
    override func awakeFromNib() {
        initUI()
    }
    
    func initUI() {
        dayPottedTextField.text = DateConvertService.convertToString(date: Date())
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(pottedDateChanged(datePicker:)), for: .valueChanged)
        datePicker?.maximumDate = Date()
        dayPottedTextField.inputView = datePicker
    }

    @objc func pottedDateChanged(datePicker: UIDatePicker) {
        dayPottedTextField.text = DateConvertService.convertToString(date: datePicker.date)
    }
}
