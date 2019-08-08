//
//  DateConvertHelper.swift
//  MyGarden
//
//  Created by Olesya Tranina on 09/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation

class DateConvertHelper {
    static func convertToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        return dateFormatter.string(from: date)
    }
}
