//
//  UserNotification.swift
//  MyGarden
//
//  Created by Olesya Tranina on 11/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation
import UserNotifications

class UserNotificationService {
    
    static func updateNotification(plant: Plant) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if success {
                DispatchQueue.global(qos: .background).async {
                    guard let identifier = plant.name else {
                        return
                    }
                    self.removeNotification(with: [identifier])
                    self.createNotification(identifier: identifier, plant: plant)
                }
            }
        }
    }
    
    private static func createNotification(identifier: String, plant: Plant) {
        guard let nextWateringTime = plant.nextWateringTime else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = "Time to water your plants!"
        content.body = "Don't forget to water \(identifier) today"
        
        let dateComponents = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: nextWateringTime)
        print(nextWateringTime)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    private static func removeNotification(with identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    
    static func getNextWateringTime(plant: Plant) -> Date? {
        guard let plantLastWatered = plant.lastWatered,
            let wateringTime = UserDefaults.standard.object(forKey: plant.wateringTime.rawValue) as? Date else {
            return nil
        }
        var lastWaterdDateComponents = Calendar.current.dateComponents([.day, .month, .year], from: plantLastWatered)
        let wateringTimeDateComponents = Calendar.current.dateComponents([.minute, .hour], from: wateringTime)
        lastWaterdDateComponents.second = 0
        lastWaterdDateComponents.minute = wateringTimeDateComponents.minute
        lastWaterdDateComponents.hour = wateringTimeDateComponents.hour
        let lastWatered = Calendar.current.date(from: lastWaterdDateComponents)!
        
        
        let dateNextWatering = Date(timeInterval: TimeInterval(24 * 60 * 60 * Int(plant.waterSchedule)), since: lastWatered)
        let dateComponents = Calendar.current.dateComponents([.second, .minute, .hour, .day, .month, .year], from: dateNextWatering)
        let nextWateringTime = Calendar.current.date(from: dateComponents)!
        return nextWateringTime
    }
    
}
