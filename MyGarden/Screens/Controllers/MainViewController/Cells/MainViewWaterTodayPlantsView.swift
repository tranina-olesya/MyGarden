//
//  MainViewWaterTodayPlantsView.swift
//  MyGarden
//
//  Created by Olesya Tranina on 16/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class MainViewWaterTodayPlantsView: UICollectionReusableView {
        
    @IBOutlet weak var waterTodayPlantsCollectionView: UICollectionView!
    
    var waterTodayPlants = [Plant]()
    
    lazy var dataProvider = DataProvider(context: CoreDataStack.shared.persistentContainer.viewContext)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }
    
    func configureView(plants: [Plant]) {
        self.waterTodayPlants = plants
        waterTodayPlantsCollectionView.reloadData()
    }
  
    
    func configureCollectionView() {
        waterTodayPlantsCollectionView.delegate = self
        waterTodayPlantsCollectionView.dataSource = self
    }
}

extension MainViewWaterTodayPlantsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return waterTodayPlants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainViewWaterTodayPlantCell", for: indexPath) as? MainViewWaterTodayPlantCell else {
            return UICollectionViewCell()
        }
        cell.plant = waterTodayPlants[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 110, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MainViewWaterTodayPlantCell else {
            return
        }
        
        cell.cellSelected()
        
        let plant = waterTodayPlants[indexPath.row]
        plant.lastWatered = Date()
        plant.nextWateringTime = UserNotificationService.getNextWateringTime(plant: plant)
        dataProvider.savePlant(plant: plant)
        UserNotificationService.updateNotification(plant: plant)

    }
}
