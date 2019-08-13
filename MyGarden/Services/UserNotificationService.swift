//
//  UserNotification.swift
//  MyGarden
//
//  Created by Olesya Tranina on 11/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation
import UserNotifications

//let notificationsTime: [WateringTime: DateComponents] = {
//    var values : [WateringTime: DateComponents] = [:]
//    
//    var dateConponents = DateComponents()
//    dateConponents.minute = 0
//    dateConponents.second = 0
//    
//    dateConponents.hour = 8
//    values[.morning] = dateConponents
//    
//    dateConponents.hour = 20
//    values[.evening] = dateConponents
//    
//    return values
//}()
let notificationsTime: [WateringTime: Int] = [.morning: 8, .evening: 20]

class UserNotificationService {
    
    static func updateNotification(plant: Plant) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if success {
                guard let identifier = plant.name else {
                    return
                }
                removeNotification(with: [identifier])
                self.createNotification(identifier: identifier, plant: plant)
            }
        }
    }
    
    private static func createNotification(identifier: String, plant: Plant) {
        guard let lastWatered = plant.lastWatered else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to water your plants!"
        content.body = "Don't forget to water \(identifier) today"
        
        let dateNextWatering = Date(timeInterval: TimeInterval(24 * 60 * 60 * Int(plant.waterSchedule)), since: lastWatered)
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = calendar.dateComponents([.day, .month, .year], from: dateNextWatering)
        dateComponents.second = 0
        dateComponents.minute = 0
        dateComponents.hour = notificationsTime[plant.wateringTime]
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
    
}
