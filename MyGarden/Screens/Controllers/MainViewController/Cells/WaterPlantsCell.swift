//
//  WaterPlantsCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 10/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class WaterPlantsCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var plants: [Plant] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }

    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configureCell(plants: [Plant]) {
        self.plants = plants
        collectionView.reloadData()
    }
}

extension WaterPlantsCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterNotificationCell", for: indexPath) as? WaterNotificationCell else {
            return UICollectionViewCell()
        }
        cell.plant = plants[indexPath.row]
        return cell
    }
}
