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
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        configureKeyboardEvents()
        configureTapRecognizer()
    }

    @IBAction func addImage(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Add image", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.dismiss(animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "From gallery", style: .default, handler: { (action) in
            
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(image, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Open camera", style: .default, handler: { (action) in
            let image = UIImagePickerController()
            image.delegate = self
            image.sourceType = UIImagePickerController.SourceType.camera
            self.present(image, animated: true)
        }))
        present(actionSheet, animated: true)
    }
    
    func initUI() {
        dayPottedTextField.text = DateConvertHelper.convertToString(date: Date())
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(pottedDateChanged(datePicker:)), for: .valueChanged)
        datePicker?.maximumDate = Date()
        dayPottedTextField.inputView = datePicker
        
        wateringTimePicker = UIPickerView()
        wateringTimePicker?.dataSource = self
        wateringTimePicker?.delegate = self
        wateringTimeTextField.inputView = wateringTimePicker
    }
    
    func configureTapRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let name = nameTextField.text,
            let wateringTimeRaw = wateringTimeTextField.text,
            let wateringTime = WateringTime(rawValue: wateringTimeRaw),
            let date = datePicker?.date {
            let success = CoreDataHelper.savePlant(name: name, description: descriptionTextField.text, wateringTime: wateringTime, dayPotted: date)
            if success {
                let plantsCount = CoreDataHelper.getAllPlants().count
                if plantsCount > 0 {
                    
                }
                UserNotification.updateNotifications()
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    @objc func pottedDateChanged(datePicker: UIDatePicker) {
        dayPottedTextField.text = DateConvertHelper.convertToString(date: datePicker.date)
    }
    
    @objc func viewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func configureKeyboardEvents() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        view.frame.origin.y = -keyboardRect.height
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        view.frame.origin.y = 0
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

extension EditPlantViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        plantImageView.image = image
        dismiss(animated: true, completion: nil)
    }
}
