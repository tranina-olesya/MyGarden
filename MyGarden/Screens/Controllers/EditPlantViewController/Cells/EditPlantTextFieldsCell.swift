//
//  FieldCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 12/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class EditPlantTextFieldsCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var plantTextField: UITextField!
    
    @IBOutlet weak var wateringTimeTextField: UITextField!
    
    @IBOutlet weak var waterScheduleTextField: UITextField!
    
    @IBOutlet weak var dayPottedTextField: UITextField!
   
    var waterSchedulePicker: UIPickerView?
    
    var datePicker: UIDatePicker?
    
    var wateringTimePicker: UIPickerView?
    
    var plantKindPicker: UIPickerView?
    
    static let wateringTimeValues: [String] = {
        var values = [String]()
        for enumValue in WateringTime.allCases {
            values.append(enumValue.rawValue)
        }
        return values
    }()
    
    var plant: Plant? {
        didSet {
            if let plant = plant {
                nameTextField.text = plant.name
                descriptionTextField.text = plant.descriptionText
                print(plant.plantKind)
                plantTextField.text = plant.plantKind ?? "Other"
                wateringTimeTextField.text = plant.wateringTime.rawValue
                waterScheduleTextField.text = Plant.waterScheduleValues[Int(plant.waterSchedule)]
                dayPottedTextField.text = DateConvertService.convertToString(date: plant.dayPotted ?? Date())
            }
        }
    }

    var plantEntries: [PlantEntry] = [] {
        didSet {
            plantTextField.isEnabled = plantEntries.count > 0
        }
    }
    
    var waterSchedulePickerDelegateDataSourse = WaterSchedulePickerDelegateDataSourse()
    
    var wateringTimePickerDelegateDataSourse = WateringTimePickerDelegateDataSourse()

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    func configureCell(plantEntries: [PlantEntry], plant: Plant?) {
        self.plantEntries = plantEntries
        self.plant = plant
        configurePlantKindPicker()
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

extension EditPlantTextFieldsCell: WaterSchedulePickerDelegate, WateringTimePickerDelegate {
    func didSelectedWateringTime(row: Int) {
        wateringTimeTextField.text = EditPlantTextFieldsCell.wateringTimeValues[row]
    }
    
    func didSelectedWaterSchedule(row: Int) {
        waterScheduleTextField.text = Plant.waterScheduleValues[row]
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
        return Plant.waterScheduleValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Plant.waterScheduleValues.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectedWaterSchedule(row: row)
    }
}


class WateringTimePickerDelegateDataSourse: NSObject,  UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate: WateringTimePickerDelegate?
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return EditPlantTextFieldsCell.wateringTimeValues.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return EditPlantTextFieldsCell.wateringTimeValues[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.didSelectedWateringTime(row: row)
    }
}

extension EditPlantTextFieldsCell: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return plantEntries.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "Other" : plantEntries[row - 1].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        plantTextField.text = row == 0 ? "Other" : plantEntries[row - 1].name
    }
}
