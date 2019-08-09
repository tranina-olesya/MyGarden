//
//  CoreDataHelper.swift
//  MyGarden
//
//  Created by Olesya Tranina on 08/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation
import UIKit

class CoreDataHelper {
    static func savePlant(name: String, description: String?, wateringTime: WateringTime, dayPotted: Date) -> Bool {
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let plant = Plant(context: context)
            plant.name = name
            plant.descriptionText = description
            plant.dayPotted = dayPotted
            plant.wateringTime = wateringTime
            try context.save()
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    static func getAllPlants() -> [Plant] {
        do {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            guard let result = try context.fetch(Plant.fetchRequest()) as? [Plant] else {
                return []
            }
            return result

        } catch {
            print(error)
            return []
        }
    }
}
