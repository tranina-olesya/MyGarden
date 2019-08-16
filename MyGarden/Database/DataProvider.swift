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
        DispatchQueue.global(qos: .background).async {
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
        DispatchQueue.global(qos: .background).async {
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
        DispatchQueue.global(qos: .background).async {
            do {
                try self.context.save()
                UserNotificationService.updateNotification(plant: plant)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func deletePlant(
        name: String, 
        onComplete: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name = %@", name)
            
            guard let plant = try? self.context.fetch(fetchRequest).first else {
                onComplete(false)
                return
            }
            
            self.context.delete(plant)
            onComplete(true)
        }
    }
}
