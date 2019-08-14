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
        case fields
    }
   
    @IBOutlet weak var tableView: UITableView!
    
    let dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
    var plantEntries: [PlantEntry] = []
    
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
        loadWikiInforamtion()
    }
    
    func loadWikiInforamtion() {
        ApiService.getWikiInfo(onCompleted: { (plantEntries) in
            self.plantEntries = plantEntries
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: Sections.fields.rawValue)) as? TextFieldCell {
                    cell.plantEntries = plantEntries
                    cell.plantTextField.isEnabled = true
                }
            }
        }) { (error) in
            print("Unable to load plant entries from Wiki")
        }
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
            let image = imageCell.plantImageView.image?.fixOrientation(),
            let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.fields.rawValue)) as? TextFieldCell,
            let name = cell.nameTextField.text,
            let description = cell.descriptionTextField.text,
            let wateringTime = WateringTime(rawValue: cell.wateringTimeTextField.text ?? ""),
            let waterSchedule = Int(cell.waterScheduleTextField.text ?? ""),
            let dayPotted = DateConvertService.convertToDate(dateString: cell.dayPottedTextField.text ?? ""),
            let plantEntry = plantEntries.first(where: { $0.name == cell.plantTextField.text }){
            if let pathUrl = ImageSaveService.saveImage(name: name, image: image) {
                dataProvider.savePlant(name: name, description: description, wateringTime: wateringTime, dayPotted: dayPotted, waterSchedule: waterSchedule, photoUrl: pathUrl, plantEntry: plantEntry)
                navigationController?.popViewController(animated: true)
            }
        }
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
        case .fields:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as? TextFieldCell else {
                return UITableViewCell()
            }
            cell.configureCell(plantEntries: plantEntries)
            cell.plantTextField.isEnabled = plantEntries.count > 0
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
