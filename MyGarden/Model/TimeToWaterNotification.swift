//
//  WaterSchedule.swift
//  MyGarden
//
//  Created by Olesya Tranina on 11/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation

class TimeToWaterNotification {
    let plantsCount: Int
    let dateComponents: DateComponents
    
    init(plantsCount: Int, dateComponents: DateComponents) {
        self.plantsCount = plantsCount
        self.dateComponents = dateComponents
    }
}
