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
        case delete
    }
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    let dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
    var plantEntries: [PlantEntry] = []
    
    var plant: Plant?
    
    var plantImage: UIImage?
    
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
        navigationController?.designTransparent()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? EditPlantImageCell {
            cell.handleScroll(offset: offset)
        }
    }
    
    func loadWikiInforamtion() {
        ApiService.getWikiInfo(onCompleted: { (plantEntries) in
            self.plantEntries = plantEntries
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: Sections.fields.rawValue)) as? EditPlantTextFieldsCell {
                    cell.plantEntries = plantEntries
                    cell.plantTextField.isEnabled = true
                    cell.plantTextField.text = plantEntries[0].name
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
        guard let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.image.rawValue)) as? EditPlantImageCell,
            let image = imageCell.plantImageView.image?.fixOrientation() else {
            showAlert(title: "No image", message: "Please add an image of your plant")
            return
        }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.fields.rawValue)) as? EditPlantTextFieldsCell,
            let name = cell.nameTextField.text,
            !name.isEmpty else {
            showAlert(title: "No name", message: "Please add a name for your plant")
            return
        }
        
        dataProvider.checkIfUniqueName(name: name, onComplete: {
            (isUnique) in
            
            if !isUnique {
                DispatchQueue.main.async {
                    self.showAlert(title: "Not a unique name", message: "Plant with name \"\(name)\" alresy exists")
                }
                return
            }
            
            if let description = cell.descriptionTextField.text,
                let wateringTime = WateringTime(rawValue: cell.wateringTimeTextField.text ?? ""),
                let waterSchedule = Int(cell.waterScheduleTextField.text ?? ""),
                let dayPotted = DateConvertService.convertToDate(dateString: cell.dayPottedTextField.text ?? ""),
                let plantEntry = self.plantEntries.first(where: { $0.name == cell.plantTextField.text }){
                if let pathUrl = ImageStorageService.saveImage(name: name, image: image) {
                    if let plant = self.plant {
                        plant.name = name
                        plant.descriptionText = description
                        plant.dayPotted = dayPotted
                        plant.wateringTime = wateringTime
                        plant.waterSchedule = Int16(waterSchedule)
                        plant.lastWatered = Date()
                        plant.photoUrl = pathUrl
                        plant.plantKind = plantEntry.name
                        plant.wikiDescription = plantEntry.description
                        self.dataProvider.savePlant(plant: plant)
                    } else {
                        self.dataProvider.savePlant(name: name, description: description, wateringTime: wateringTime, dayPotted: dayPotted, waterSchedule: waterSchedule, photoUrl: pathUrl, plantEntry: plantEntry)
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            // error
        }, onError: {
            (error) in
            // error
        })
        
       
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
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
        tableViewBottomConstraint.constant = keyboardRect.height
        navigationController?.navigationBar.isHidden = true
    }

    @objc func keyboardWillHide(notification: Notification) {
        tableViewBottomConstraint.constant = 0
        navigationController?.navigationBar.isHidden = false
    }
}

extension EditPlantViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let cellCount = Sections.allCases.count
        return plant != nil ? cellCount : cellCount - 1
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPlantImageCell", for: indexPath) as? EditPlantImageCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configureCell(image: plantImage)
            return cell
        case .fields:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPlantTextFieldsCell", for: indexPath) as? EditPlantTextFieldsCell else {
                return UITableViewCell()
            }
            cell.configureCell(plantEntries: plantEntries, plant: plant)
//            cell.plantTextField.isEnabled = plantEntries.count > 0
            return cell
        case .delete:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPlantDeleteCell", for: indexPath) as? EditPlantDeleteCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Sections(rawValue: indexPath.section) else {
            return 0.0
        }
        
        switch sectionType {
        case .image:
            return 300.0
        case .fields:
            return 520.0
        case .delete:
            return 90.0
        }
    }
}

extension EditPlantViewController: EditPlantImageCellDelegate {
    func presentView(_ view: UIViewController, animated: Bool) {
        present(view, animated: animated)
    }
    
    func dismiss(animated: Bool) {
        dismiss(animated: true, completion: nil)
    }
}

extension EditPlantViewController: EditPlantDeleteCellDelegate {
    func didPressDeleteButton() {
        guard let plant = plant else {
            return
        }
        dataProvider.deletePlant(plant: plant) { (complete) in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
