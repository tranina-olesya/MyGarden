//
//  UserNotification.swift
//  MyGarden
//
//  Created by Olesya Tranina on 11/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation
import UserNotifications

let notificationsTime: [WateringTime: DateComponents] = {
    var values : [WateringTime: DateComponents] = [:]
    
    var dateConponents = DateComponents()
    dateConponents.minute = 0
    dateConponents.second = 0
    
    dateConponents.hour = 8
    values[.morning] = dateConponents
    
    dateConponents.hour = 20
    values[.evening] = dateConponents
    
    return values
}()


class UserNotification {
    
    static func sendNotification(identifier: String, notification: TimeToWaterNotification) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (success, error) in
            if success {
                self.createNotification(identifier: identifier, timeToWaterNotification: notification)
            }
        }
    }
    
    private static func createNotification(identifier: String, timeToWaterNotification: TimeToWaterNotification) {
        removeNotification(with: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Time to water your plants!"
        content.body = "\(timeToWaterNotification.plantsCount) \(timeToWaterNotification.plantsCount == 1 ? "plant is" : "plants are") wating for water"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: timeToWaterNotification.dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
    static func removeNotification(with identifiers: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    static func updateNotifications() {
        for enumValue in WateringTime.allCases {
            let plants = CoreDataHelper.gelAllPlants(wateringTime: enumValue)
            if plants.count > 0,
                let dateComponents = notificationsTime[enumValue] {
                sendNotification(identifier: enumValue.rawValue, notification: TimeToWaterNotification(plantsCount: plants.count, dateComponents: dateComponents))
            }
        }
    }
}
