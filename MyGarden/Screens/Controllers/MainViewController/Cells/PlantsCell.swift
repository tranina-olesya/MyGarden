//
//  PlantsCell.swift
//  MyGarden
//
//  Created by Olesya Tranina on 10/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit

class PlantsCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    static let cellMarginSize: CGFloat = 10
    static let cellRatio: CGFloat = 1.4

    var plants: [Plant]?
    
    var cellSize: CGSize {
        get {
            let screenWidth = frame.width
            let cellWidth = screenWidth / 2 - CGFloat(PlantsCell.cellMarginSize * 2)
            let cellHeight = cellWidth * PlantsCell.cellRatio
            return CGSize(width: cellWidth, height: cellHeight)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func configureCell(plants: [Plant]?) {
        self.plants = plants
        collectionView.reloadData()
    }
}

extension PlantsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plants?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantCell", for: indexPath) as? PlantCell else {
            return UICollectionViewCell()
        }
        cell.plant = plants?[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
