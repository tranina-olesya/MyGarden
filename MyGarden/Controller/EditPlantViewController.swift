//
//  EditPlantViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 07/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class EditPlantViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var plantImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var wateringTimeTextField: UITextField!
    
    @IBOutlet weak var dayPottedTextField: UITextField!
    
    private var datePicker: UIDatePicker?
    
    private var wateringTimePicker: UIPickerView?
    
    private let wateringTimeValues: [String] = {
        var values = [String]()
        for enumValue in WateringTime.allCases {
            values.append(enumValue.rawValue)
        }
        return values
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }

    func initUI() {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: dayPottedTextField.frame.origin.y + dayPottedTextField.frame.height)
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(pottedDateChanged(datePicker:)), for: .valueChanged)
        dayPottedTextField.inputView = datePicker
        
        wateringTimePicker = UIPickerView()
        wateringTimePicker?.dataSource = self
        wateringTimePicker?.delegate = self
        wateringTimeTextField.inputView = wateringTimePicker
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
    }
    
    @objc func pottedDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        dayPottedTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @objc func viewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

extension EditPlantViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
