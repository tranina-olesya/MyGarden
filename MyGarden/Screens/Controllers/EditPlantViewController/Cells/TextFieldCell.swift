//
//  FieldCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var plantTextField: UITextField!
    
    @IBOutlet weak var wateringTimeTextField: UITextField!
    
    @IBOutlet weak var waterScheduleTextField: UITextField!
    
    @IBOutlet weak var dayPottedTextField: UITextField!
   
    private var waterSchedulePicker: UIPickerView?
    
    private var datePicker: UIDatePicker?
    
    private var wateringTimePicker: UIPickerView?
    
    private var plantKindPicker: UIPickerView?
    
    static let wateringTimeValues: [String] = {
        var values = [String]()
        for enumValue in WateringTime.allCases {
            values.append(enumValue.rawValue)
        }
        return values
    }()
    
    static let waterScheduleValues: [String] = {
        var values = ["Every day"]
        for day in 2...14 {
            values.append("Every \(day) days")
        }
        return values
    }()

    var plantEntries: [PlantEntry] = []
    
    var waterSchedulePickerDelegateDataSourse = WaterSchedulePickerDelegateDataSourse()
    
    var wateringTimePickerDelegateDataSourse = WateringTimePickerDelegateDataSourse()

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func configureCell(plantEntries: [PlantEntry]) {
        self.plantEntries = plantEntries
        configurePlantKindPicker()
        if plantEntries.count > 0 {
            plantTextField.text = plantEntries[0].name
        }
    }
    
    func initUI() {
        configureDayPottedTextField()
        configureWaterSchedulePicker()
        configureWateringTimePicker()
    }
    
    func configureDayPottedTextField() {
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
    
    func configureWaterSchedulePicker() {
        waterSchedulePickerDelegateDataSourse.delegate = self
        waterSchedulePicker = UIPickerView()
        waterSchedulePicker?.dataSource = waterSchedulePickerDelegateDataSourse
        waterSchedulePicker?.delegate = waterSchedulePickerDelegateDataSourse
        waterScheduleTextField.inputView = waterSchedulePicker
    }
    
    func configureWateringTimePicker() {
        wateringTimePickerDelegateDataSourse.delegate = self
        wateringTimePicker = UIPickerView()
        wateringTimePicker?.dataSource = wateringTimePickerDelegateDataSourse
        wateringTimePicker?.delegate = wateringTimePickerDelegateDataSourse
        wateringTimeTextField.inputView = wateringTimePicker
    }
    
    func configurePlantKindPicker() {
        plantKindPicker = UIPickerView()
        plantKindPicker?.dataSource = self
        plantKindPicker?.delegate = self
        plantTextField.inputView = plantKindPicker
    }
    
}

extension TextFieldCell: WaterSchedulePickerDelegate, WateringTimePickerDelegate {
    func didSelectedWateringTime(row: Int) {
        wateringTimeTextField.text = TextFieldCell.wateringTimeValues[row]
    }
    
    func didSelectedWaterSchedule(row: Int) {
        waterScheduleTextField.text = String(row + 1)
    }
}

protocol WateringTimePickerDelegate: class {
    func didSelectedWateringTime(row: Int)
}

protocol WaterSchedulePickerDelegate: class {
    func didSelectedWaterSchedule(row: Int)
}

class WaterSchedulePickerDelegateDataSourse: NSObject,  UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: WaterSchedulePickerDelegate?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TextFieldCell.waterScheduleValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TextFieldCell.waterScheduleValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectedWaterSchedule(row: row)
        
    }
}


class WateringTimePickerDelegateDataSourse: NSObject,  UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: WateringTimePickerDelegate?
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return TextFieldCell.wateringTimeValues.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return TextFieldCell.wateringTimeValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectedWateringTime(row: row)
    }
}

extension TextFieldCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return plantEntries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return plantEntries[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        plantTextField.text = plantEntries[row].name
    }
}
