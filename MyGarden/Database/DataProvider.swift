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
                plant.nextWateringTime = UserNotificationService.getNextWateringTime(plant: plant)
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
        plant: Plant,
        onComplete: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            do {
                self.context.delete(plant)
                try self.context.save()
                onComplete(true)
            } catch {
                print(error)
                onComplete(false)
            }
        }
    }
    
    func checkIfUniqueName(
        name: String,
        onComplete: @escaping (Bool) -> Void,
        onError: @escaping (Error) -> Void) {
        do {
            let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name = %@", name)
            let isUnique = try self.context.fetch(fetchRequest).first == nil
            onComplete(isUnique)
        } catch {
            print(error)
            onError(error)
        }
    }
}
