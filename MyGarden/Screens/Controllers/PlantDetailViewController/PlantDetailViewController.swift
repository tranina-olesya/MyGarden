//
//  PlantDetailViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 09/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class PlantDetailViewController: UIViewController {
    
    private enum Sections: Int, CaseIterable {
        case image
        case name
        case description
        case wateringTime
        case waterSchedule
        case dayPotted
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
        print(offset)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? PlantDetailImageCell {
            cell.handleScroll(offset: offset)
        }
    }
}

extension PlantDetailViewController: UITableViewDelegate, UITableViewDataSource {
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantDetailImageCell", for: indexPath) as? PlantDetailImageCell else {
                return UITableViewCell()
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
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Sections(rawValue: indexPath.section) else {
            return 0.0
        }
        
        switch sectionType {
        case .image:
            return 300.0
        default:
            return 98.0
        }
    }
}