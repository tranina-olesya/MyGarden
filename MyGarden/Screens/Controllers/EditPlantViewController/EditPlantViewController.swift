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
    
    struct SectionSize {
        static let image: CGFloat = 300.0
        static let fields: CGFloat = 520.0
        static let delete: CGFloat = 90.0
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
        guard plantImage != nil else {
            showAlert(title: "No image", message: "Please add an image of your plant")
            return
        }

        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.fields.rawValue)) as? EditPlantTextFieldsCell,
            let name = cell.nameTextField.text,
            !name.isEmpty else {
            showAlert(title: "No name", message: "Please add a name for your plant")
            return
        }
        
        if let plant = plant,
            name == plant.name {
            savePlant()
        } else {
            dataProvider.checkIfUniqueName(name: name, onComplete: {
                (isUnique) in
                guard isUnique else {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Not a unique name", message: "Plant with name \"\(name)\" alresy exists")
                    }
                    return
                }
                self.savePlant()
            }, onError: {
                (error) in
                print(error.localizedDescription)
            })
        }
       
    }
    
    func savePlant() {
        guard let cell = tableView.cellForRow(at: IndexPath(row: 0, section: Sections.fields.rawValue)) as? EditPlantTextFieldsCell else {
                return
        }
        
        if let name = cell.nameTextField.text,
            let description = cell.descriptionTextField.text,
            let wateringTime = WateringTime(rawValue: cell.wateringTimeTextField.text ?? ""),
            let dayPotted = DateConvertService.convertToDate(dateString: cell.dayPottedTextField.text ?? ""),
            let plantImage = plantImage,
            let waterScheduleRaw = cell.waterScheduleTextField.text,
            let plantKindName = cell.plantTextField.text,
            let pathUrl = ImageStorageService.saveImage(name: name, image: plantImage.resize(width: 1000.0) ?? plantImage) {
            
            let plant = self.plant ?? Plant(context: CoreDataStack.shared.persistentContainer.viewContext)
            
            if let plantEntry = plantEntries.first(where: {$0.name == plantKindName}) {
                plant.plantKind = plantEntry.name
                plant.wikiDescription = plantEntry.description
            } else {
                plant.plantKind = nil
                plant.wikiDescription = nil
            }
            plant.name = name
            plant.descriptionText = description
            plant.dayPotted = dayPotted
            plant.wateringTime = wateringTime
            plant.waterSchedule = (getWaterSchedule(rawString: waterScheduleRaw) ?? 0) + 1
            plant.lastWatered = plant.lastWatered ?? Date()
            plant.photoUrl = pathUrl
            plant.nextWateringTime = UserNotificationService.getNextWateringTime(plant: plant)
            
            self.dataProvider.savePlant(plant: plant)
       
            self.navigationController?.popToRootViewController(animated: true)
        }
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
        tableViewBottomConstraint.constant = keyboardRect.height - (tabBarController?.tabBar.frame.size.height ?? 0)
    }

    @objc func keyboardWillHide(notification: Notification) {
        tableViewBottomConstraint.constant = 0
    }
    
    private func getWaterSchedule(rawString: String)  -> Int16? {
        for i in 1..<Plant.waterScheduleValues.count {
            if rawString == Plant.waterScheduleValues[i] {
                return Int16(i)
            }
        }
        return nil
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
            return SectionSize.image
        case .fields:
            return SectionSize.fields
        case .delete:
            return SectionSize.delete
        }
    }
}

extension EditPlantViewController: EditPlantImageCellDelegate {
    func imageAdded(image: UIImage?) {
        plantImage = image
    }
    
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
