//
//  ViewController.swift
//  MyGarden
//
//  Created by Olesya Tranina on 06/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        do {
//            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//            let plant = Plant(context: context)
//            plant.name = "11"
//            plant.dayPotted = Date()
//            plant.wateringTime = .evening
//            try context.save()
//            let result = try context.fetch(Plant.fetchRequest())
//            print(result)
//        } catch {
//            print(error)
//        }
    }

    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "showPlant", sender: nil)
    }
}

