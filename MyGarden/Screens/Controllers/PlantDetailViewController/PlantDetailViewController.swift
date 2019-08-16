//
//  PlantDetailViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 09/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

enum PlantDetailViewSegue: String {
    case editPlant = "showEditPlant"
}

class PlantDetailViewController: UIViewController {
    
    private enum Sections: Int, CaseIterable {
        case image
        case name
        case description
        case wateringTime
        case waterSchedule
        case dayPotted
        case plantKind
        case wikiDescription
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var plant: Plant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        navigationController?.designTransparent()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
 
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PlantDetailImageCell {
            cell.handleScroll(offset: offset)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let plantDetailSegue = PlantDetailViewSegue(rawValue: segue.identifier ?? "") else {
            return
        }
        
        switch plantDetailSegue {
        case .editPlant:
            guard let vc = segue.destination as? EditPlantViewController,
                let imageCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PlantDetailImageCell else {
                return
            }
            vc.plant = plant
            vc.plantImage = imageCell.plantImageView.image
        }
    }
}

extension PlantDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return plant?.plantKind != nil ? Sections.allCases.count : Sections.allCases.count - 2
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailImageCell", for: indexPath) as? PlantDetailImageCell else {
                return UITableViewCell()
            }
            if let name = plant?.name {
                ImageStorageService.getSavedImage(name: name) { (image) in
                    let resizedImage = image?.resize(width: 500)
                    DispatchQueue.main.async {
                        if resizedImage != nil {
                            cell.configureCell(image: resizedImage)
                        } else {
                            cell.configureCell(image: image)
                        }
                    }
                }
            }
            return cell
        case .name:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailFieldCell", for: indexPath) as? PlantDetailFieldCell else {
                return UITableViewCell()
            }
            cell.configureCell(fieldName: "Name", fieldValue: plant?.name ?? "")
            return cell
        case .description:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailFieldCell", for: indexPath) as? PlantDetailFieldCell else {
                return UITableViewCell()
            }
            cell.configureCell(fieldName: "Description", fieldValue: plant?.descriptionText ?? "")
            return cell
        case .wateringTime:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailFieldCell", for: indexPath) as? PlantDetailFieldCell else {
                return UITableViewCell()
            }
            cell.configureCell(fieldName: "Watering Time", fieldValue: plant?.wateringTime.rawValue ?? "")
            return cell
        case .dayPotted:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailFieldCell", for: indexPath) as? PlantDetailFieldCell else {
                return UITableViewCell()
            }
            if let dayPotted = plant?.dayPotted {
                cell.configureCell(fieldName: "Day Potted", fieldValue: DateConvertService.convertToString(date: dayPotted))
            }
            return cell
        case .waterSchedule:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailFieldCell", for: indexPath) as? PlantDetailFieldCell else {
                return UITableViewCell()
            }
            if let waterSchedule = plant?.waterSchedule {
                cell.configureCell(fieldName: "Water Schedule", fieldValue: String(waterSchedule))
            }
            return cell
        case .plantKind:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailFieldCell", for: indexPath) as? PlantDetailFieldCell else {
                return UITableViewCell()
            }
            if let plantKind = plant?.plantKind {
                cell.configureCell(fieldName: "Plant", fieldValue: plantKind)
            }
            return cell
        case .wikiDescription:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailFieldCell", for: indexPath) as? PlantDetailFieldCell else {
                return UITableViewCell()
            }
            if let wikiDescription = plant?.wikiDescription {
                cell.configureCell(fieldName: "Wiki description", fieldValue: wikiDescription)
            }
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
        case .wikiDescription:
            return 200.0
        default:
            return 78.0
        }
    }
}
