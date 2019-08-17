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
    
    @IBOutlet weak var allPlantsCollectionView: UICollectionView!
    
    var plants: [Plant] = []
    var waterNotificationPlants: [Plant] = []
    
    let dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
    var allPlantsCellSize: CGSize = CGSize(width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    func configureCollectionView() {
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
                let index = allPlantsCollectionView.indexPathsForSelectedItems?.first?.row else {
                    return
            }
            vc.plant = plants[index]
        }
    }
    
    func updateCellSize(screenWidth: CGFloat) {
        let cellWidth = screenWidth / 2 - CGFloat(Constatnts.cellMarginSize * 2)
        let cellHeight = cellWidth * Constatnts.cellRatio + Constatnts.cellMarginSize
        
        allPlantsCellSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
    func updateCollectionViews() {
        self.dataProvider.getAllPlants { (plants) in
            DispatchQueue.main.async {
                self.plants = plants
                self.waterNotificationPlants = self.formWaterNotificationPlatsArray(plants: plants)
                self.allPlantsCollectionView.reloadData()
            }
        }
    }

    func formWaterNotificationPlatsArray(plants: [Plant]) -> [Plant] {
        let nowDate = Calendar.current.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(), to: Date())!
        var waterNotificationPlants = [Plant]()
        for plant in plants {
            if let nextWateringTime = plant.nextWateringTime,
                nextWateringTime < nowDate {
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewPlantCell", for: indexPath) as? MainViewPlantCell else {
            return UICollectionViewCell()
        }
        cell.plant = plants[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return allPlantsCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MainViewWaterTodayPlantsView", for: indexPath) as? MainViewWaterTodayPlantsView else {
            return UICollectionReusableView()
        }
        view.configureView(plants: waterNotificationPlants)
        return view
    }

}
