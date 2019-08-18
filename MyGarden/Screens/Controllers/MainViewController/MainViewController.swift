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
        static let noPlantsHeaderHeight: CGFloat = 178
        static let waterTodayPlantsHeaderHeight: CGFloat = 326
        static let noPlantsCellHeight: CGFloat = 300
    }
    
    private enum Sections: Int {
        case plants
        case emptyMessage
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var plants: [Plant] = []
    var waterTodayPlants: [Plant] = []
    
    let dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
    var allPlantsCellSize: CGSize = CGSize(width: 0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
    }

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
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
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mainViewSegue = MainViewSegue(rawValue: segue.identifier ?? "") else {
            return
        }
        switch mainViewSegue {
        case .plantDetail:
            guard let vc = segue.destination as? PlantDetailViewController,
                let index = collectionView.indexPathsForSelectedItems?.first?.row else {
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
                self.waterTodayPlants = self.formWaterNotificationPlatsArray(plants: plants)
                self.collectionView.reloadData()
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
        return max(plants.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !plants.isEmpty else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewEmptyMessageCell", for: indexPath) as? MainViewEmptyMessageCell else {
                return UICollectionViewCell()
            }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewPlantCell", for: indexPath) as? MainViewPlantCell else {
            return UICollectionViewCell()
        }
        cell.plant = plants[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard !plants.isEmpty else {
            return CGSize(width: view.frame.width, height: Constatnts.noPlantsCellHeight)
        }
        return allPlantsCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "MainViewWaterTodayPlantsView", for: indexPath) as? MainViewWaterTodayPlantsView else {
            return UICollectionReusableView()
        }
        view.configureView(plants: waterTodayPlants)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if waterTodayPlants.isEmpty {
            return CGSize(width: view.frame.width, height: Constatnts.noPlantsHeaderHeight)
        } else {
            return CGSize(width: view.frame.width, height: Constatnts.waterTodayPlantsHeaderHeight)
        }
    }
}
