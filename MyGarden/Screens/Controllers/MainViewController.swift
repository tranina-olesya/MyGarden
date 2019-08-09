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
    case plant = "showDetail"
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    let cellMarginSize: CGFloat = 10
    let cellRatio: CGFloat = 1.4
    
    var plants: [Plant]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        updateCollectionView()
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        updateCollectionView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let mainViewSegue = MainViewSegue(rawValue: segue.identifier ?? ""),
            let indexPath = collectionView.indexPathsForSelectedItems?.first,
            let plant = plants?[indexPath.row] else {
            return
        }
        switch mainViewSegue {
        case .plant:
            let vc = segue.destination as? PlantDetailViewController
            vc?.plant = plant
        }
    }
    
    func updateCollectionView() {
        plants = CoreDataHelper.getAllPlants()
        collectionView.reloadData()
        collectionViewHeightConstraint.constant = getCollectionViewHeight()
        view.layoutIfNeeded()
    }
    
    func getCollectionViewHeight() -> CGFloat {
        let screenWidth = view.frame.width
        let cellWidth = screenWidth / 2 - CGFloat(cellMarginSize * 2)
        let cellHeight = cellWidth * cellRatio + cellMarginSize * 2
        return ceil(CGFloat(plants?.count ?? 0) / 2.0) * cellHeight
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        let screenWidth = view.frame.width
        let cellWidth = screenWidth / 2 - CGFloat(cellMarginSize * 2)
        let cellHeight = cellWidth * cellRatio
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
