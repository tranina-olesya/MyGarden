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
    case plantDetail = "showPlantDetail"
}

class MainViewController: UIViewController {
    private struct Constatnts {
        static let cellMarginSize: CGFloat = 10
        static let cellRatio: CGFloat = 1.4
    }
    
    private enum Sections: Int {
        case waterPlantsCell
        case plantsCell
    }
    
    @IBOutlet weak var waterTodayPlantsCollectionView: UICollectionView!
    
    @IBOutlet weak var allPlantsCollectionView: UICollectionView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var containerViewHeightContraint: NSLayoutConstraint!
    
    var plants: [Plant] = []
    var waterNotificationPlants: [Plant] = []
    
    let dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
    var allPlantsCellSize: CGSize = CGSize(width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionViews()
    }

    func configureCollectionViews() {
        waterTodayPlantsCollectionView.delegate = self
        waterTodayPlantsCollectionView.dataSource = self
        allPlantsCollectionView.delegate = self
        allPlantsCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        updateCellSize(screenWidth: view.frame.width)
        updateCollectionViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateCellSize(screenWidth: size.width)
        allPlantsCollectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mainViewSegue = MainViewSegue(rawValue: segue.identifier ?? "") else {
            return
        }
        switch mainViewSegue {
        case .plantDetail:
            guard let vc = segue.destination as? PlantDetailViewController,
                let plant = sender as? Plant else {
                    return
            }
            vc.plant = plant
        }
    }
    
    func updateCellSize(screenWidth: CGFloat) {
        let cellWidth = screenWidth / 2 - CGFloat(Constatnts.cellMarginSize * 2)
        let cellHeight = cellWidth * Constatnts.cellRatio + Constatnts.cellMarginSize
        
        allPlantsCellSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
//    func updateCollectionViewHeight() -> CGFloat {
//        ceil(CGFloat(plants.count) / 2.0) * allPlantsCellSize.height
//    }
    
    func updateCollectionViews() {
        self.dataProvider.getAllPlants { (plants) in
            DispatchQueue.main.async {
                self.plants = plants
                self.waterNotificationPlants = self.formWaterNotificationPlatsArray(plants: plants)
                self.allPlantsCollectionView.reloadData()
                self.waterTodayPlantsCollectionView.reloadData()
            }
        }
    }

    func formWaterNotificationPlatsArray(plants: [Plant]) -> [Plant] {
        let nowDate = Date()
        var waterNotificationPlants = [Plant]()
        for plant in plants {
            guard let lastWatered = plant.lastWatered else {
                continue
            }
            let shouldWateredDate = Date(timeInterval: TimeInterval(Int(plant.waterSchedule) * 24 * 60 * 60), since: lastWatered)
            if shouldWateredDate < nowDate {
                waterNotificationPlants.append(plant)
            }
        }
        return waterNotificationPlants
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == allPlantsCollectionView {
            return plants.count
        } else {
            return waterNotificationPlants.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == allPlantsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as? PlantCell else {
                return UICollectionViewCell()
            }
            cell.plant = plants[indexPath.row]
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterNotificationCell", for: indexPath) as? WaterNotificationCell else {
                return UICollectionViewCell()
            }
            cell.plant = waterNotificationPlants[indexPath.row]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == allPlantsCollectionView {
            return allPlantsCellSize
        } else {
            return CGSize(width: 100, height: 100)
        }
    }

}
