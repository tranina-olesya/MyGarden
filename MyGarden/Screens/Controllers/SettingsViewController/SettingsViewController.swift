//
//  SettingsViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 18/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var morningTimeTextField: UITextField!
    
    @IBOutlet weak var eveningTimeTextField: UITextField!
    
    private var moringTimePicker: UIDatePicker?
    
    private var eveningTimePicker: UIDatePicker?
    
    lazy var dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureEveningTimeTextField()
        configureMorningTimeTextField()
        configureTapRecognizer()
    }
    
    func configureMorningTimeTextField() {
        let morningDate = UserDefaults.standard.object(forKey: WateringTime.morning.rawValue) as? Date ?? Date()
        moringTimePicker = UIDatePicker()
        moringTimePicker?.datePickerMode = .time
        moringTimePicker?.date = UserDefaults.standard.object(forKey: WateringTime.morning.rawValue) as? Date ?? Date()
        moringTimePicker?.addTarget(self, action: #selector(morningTimeChanged(datePicker:)), for: .valueChanged)
        morningTimeTextField.inputView = moringTimePicker
        morningTimeTextField.addTarget(self, action: #selector(didEndEditingMorningTime(textField:)), for: .editingDidEnd)
        morningTimeTextField.text = DateConvertService.convertTimeToString(date: morningDate)
    }
    
    func configureEveningTimeTextField() {
        let eveningDate = UserDefaults.standard.object(forKey: WateringTime.evening.rawValue) as? Date ?? Date()
        eveningTimePicker = UIDatePicker()
        eveningTimePicker?.datePickerMode = .time
        eveningTimePicker?.date = eveningDate
        eveningTimePicker?.addTarget(self, action: #selector(eveningTimeChanged(datePicker:)), for: .valueChanged)
        eveningTimeTextField.inputView = eveningTimePicker
        eveningTimeTextField.addTarget(self, action: #selector(didEndEditingEveningTime(textField:)), for: .editingDidEnd)
        eveningTimeTextField.text = DateConvertService.convertTimeToString(date: eveningDate)
    }
    
    @objc func morningTimeChanged(datePicker: UIDatePicker) {
        morningTimeTextField.text = DateConvertService.convertTimeToString(date: datePicker.date)
    }
    
    @objc func eveningTimeChanged(datePicker: UIDatePicker) {
         eveningTimeTextField.text = DateConvertService.convertTimeToString(date: datePicker.date)
    }
    
    func configureTapRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func viewTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func didEndEditingMorningTime(textField: UITextField) {
        guard let date = moringTimePicker?.date else {
            return
        }
        UserDefaults.standard.set(date, forKey: WateringTime.morning.rawValue)
        updateNotificationsForPlants(with: WateringTime.morning)
    }
    
    @objc func didEndEditingEveningTime(textField: UITextField) {
        guard let date = eveningTimePicker?.date else {
            return
        }
        UserDefaults.standard.set(date, forKey: WateringTime.evening.rawValue)
        updateNotificationsForPlants(with: WateringTime.evening)
    }
    
    func updateNotificationsForPlants(with wateringTime: WateringTime) {
        dataProvider.getAllPlants(with: wateringTime) { (plants) in
            for plant in plants {
                plant.nextWateringTime = UserNotificationService.getNextWateringTime(plant: plant)
                self.dataProvider.savePlant(plant: plant)
                UserNotificationService.updateNotification(plant: plant)
            }
        }
    }
}
