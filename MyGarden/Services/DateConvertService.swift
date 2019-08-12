//
//  DateConvertHelper.swift
//  MyGarden
//
//  Created by Olesya Tranina on 09/08/2019.
//  Copyright © 2019 Olesya Tranina. All rights reserved.
//

import Foundation

class DateConvertService {
    static let dateFormat = "dd MMM, yyyy"
    
    static func convertToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    static func convertToDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: dateString)
    }
}
