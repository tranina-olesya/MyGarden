//
//  EditPlantViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 07/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class EditPlantViewController: UIViewController {
    
    private enum Sections: Int, CaseIterable {
        case image
        case name
        case description
        case wateringTime
        case waterSchedule
        case dayPotted
    }
   
    @IBOutlet weak var tableView: UITableView!
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureKeyboardEvents()
        configureTapRecognizer()
        configureTableView()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func configureTapRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(tapGestureRecognizer:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if
            let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.image.rawValue)) as? PlantImageCell,
            let image = imageCell.plantImageView.image,
            let nameCell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.name.rawValue)) as? TextFieldCell,
            let name = nameCell.valueTextField.text,
            let descriptionCell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.description.rawValue)) as? TextFieldCell,
            let description = descriptionCell.valueTextField.text,
            let wateringTimeCell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.wateringTime.rawValue)) as? WateringTimePickerCell,
            let wateringTime = WateringTime(rawValue: wateringTimeCell.wateringTimeTextField.text ?? ""),
            let waterScheduleCell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.waterSchedule.rawValue)) as? WaterSchedulePickerCell,
            let waterSchedule = Int(waterScheduleCell.waterScheduleTextField.text ?? ""),
            let dayPottedCell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.dayPotted.rawValue)) as? DatePickerCell,
            let dayPotted = DateConvertService.convertToDate(dateString: dayPottedCell.dayPottedTextField.text ?? "")
        {
            if let pathUrl = ImageSaveService.saveImage(name: name, image: image) {
                let success = CoreDataService.savePlant(name: name, description: description, wateringTime: wateringTime, dayPotted: dayPotted, waterSchedule: waterSchedule, photoUrl: pathUrl)
                if success {
                    //
                } else {
                    //
                }
            }
        }
        navigationController?.popViewController(animated: true)
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

extension EditPlantViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Sections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .image:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantImageCell", for: indexPath) as? PlantImageCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        case .name:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell else {
                return UITableViewCell()
            }
            cell.configureCell(name: "Name")
            return cell
        case .description:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell else {
                return UITableViewCell()
            }
            cell.configureCell(name: "Description")
            return cell
        case .wateringTime:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WateringTimePickerCell", for: indexPath) as? WateringTimePickerCell else {
                return UITableViewCell()
            }
            return cell
        case .dayPotted:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DatePickerCell", for: indexPath) as? DatePickerCell else {
                return UITableViewCell()
            }
            return cell
        case .waterSchedule:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WaterSchedulePickerCell", for: indexPath) as? WaterSchedulePickerCell else {
                return UITableViewCell()
            }
            return cell
        }
    }
}

extension EditPlantViewController: PlantImageCellDelegate {
    func presentView(_ view: UIViewController, animated: Bool) {
        present(view, animated: animated)
    }
    
    func dismiss(animated: Bool) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
