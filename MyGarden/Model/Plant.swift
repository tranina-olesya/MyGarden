//
//  Plant.swift
//  MyGarden
//
//  Created by Olesya Tranina on 06/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation

extension Plant {
    var wateringTime: WateringTime {
        get {
            guard let wateringTimeRaw = wateringTimeRaw,
            let value = WateringTime(rawValue: wateringTimeRaw) else {
                return .morning
            }
            return value
        }
        set {
            wateringTimeRaw = newValue.rawValue
        }
    }
}
