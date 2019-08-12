//
//  ViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 06/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit
import CoreData

enum MainViewSegue: String {
    case plant = "showPlantDetail"
}

class MainViewController: UIViewController {
    
    private enum Sections: Int {
        case waterPlantsCell
        case plantsCell
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var plants: [Plant]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        plants = CoreDataService.getAllPlants()
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        updateTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mainViewSegue = MainViewSegue(rawValue: segue.identifier ?? ""),
            let plant = sender as? Plant else {
            return
        }
        switch mainViewSegue {
        case .plant:
            let vc = segue.destination as? PlantDetailViewController
            vc?.plant = plant
        }
    }
    
    func updateTableView() {
        plants = CoreDataService.getAllPlants()
        tableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        tableView.reloadData()
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource, PlantsCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let sectionType = Sections(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        switch sectionType {
        case .waterPlantsCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "WaterPlantsCell", for: indexPath) as? WaterPlantsCell else {
                return UITableViewCell()
            }
            return cell
        case .plantsCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlantsCell", for: indexPath) as? PlantsCell else {
                return UITableViewCell()
            }
            cell.delegate = self
            cell.configureCell(plants: plants)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let sectionType = Sections(rawValue: indexPath.section) else {
            return 0.0
        }
        
        switch sectionType {
        case .waterPlantsCell:
            return 243
        case .plantsCell:
            return getCollectionViewHeight() + 20 * 2 + 50
        }
    }
    
    func getCollectionViewHeight() -> CGFloat {
        let screenWidth = view.frame.width
        let cellWidth = screenWidth / 2 - CGFloat(PlantsCell.cellMarginSize * 2)
        let cellHeight = cellWidth * PlantsCell.cellRatio + PlantsCell.cellMarginSize
        return ceil(CGFloat(plants?.count ?? 0) / 2.0) * cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let sectionType = Sections(rawValue: indexPath.section) else {
            return
        }
        
        switch sectionType {
        case .waterPlantsCell:
            return
        case .plantsCell:
            guard let cell = cell as? PlantsCell else {
                return
            }
            cell.configureCell(plants: plants)
        }
    }
    
    func didSelectedItem(indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlantDetail", sender: plants?[indexPath.row])
    }
}
