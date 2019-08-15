//
//  CoreDataProvider.swift
//  MyGarden
//
//  Created by Olesya Tranina on 14/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import CoreData

class DataProvider {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getAllPlants(onComplete: @escaping ([Plant]) -> Void) {
        let mySerialQueue = DispatchQueue(label: "ru.vsu.MyGarden", qos: .background)
        mySerialQueue.async {
            do {
                guard let result = try self.context.fetch(Plant.fetchRequest()) as? [Plant] else {
                    onComplete([])
                    return
                }
                onComplete(result)
            } catch {
                print(error.localizedDescription)
                onComplete([])
            }
        }
    }
    
    func savePlant(name: String, description: String?, wateringTime: WateringTime, dayPotted: Date, waterSchedule: Int, photoUrl: String, plantEntry: PlantEntry?) {
        let mySerialQueue = DispatchQueue(label: "ru.vsu.MyGarden", qos: .background)
        mySerialQueue.async {
            do {
                let plant = Plant(context: self.context)
                plant.name = name
                plant.descriptionText = description
                plant.dayPotted = dayPotted
                plant.wateringTime = wateringTime
                plant.waterSchedule = Int16(waterSchedule)
                plant.lastWatered = Date()
                plant.photoUrl = photoUrl
                plant.plantKind = plantEntry?.name
                plant.wikiDescription = plantEntry?.description
                try self.context.save()
                UserNotificationService.updateNotification(plant: plant)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func savePlant(plant: Plant) {
        let mySerialQueue = DispatchQueue(label: "ru.vsu.MyGarden", qos: .background)
        mySerialQueue.async {
            do {
                try self.context.save()
                UserNotificationService.updateNotification(plant: plant)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
