//
//  DateUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/30/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

class DateUtils {
    // Return a formatted date string from a timestamp
    static func getDate(timestamp: Double) -> String {
        let date = Date(timeIntervalSinceReferenceDate: timestamp)
        let currentDate = Date(timeIntervalSinceNow: 0)
        
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.second], from: date, to: currentDate)
        let days = Float(dateComponents.second!) / Float(3600 * 24)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        if days < 1 {
            dateFormatter.dateFormat = "h:mm a"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        } else if days < 2 {
            return "Yesterday"
        } else {
            dateFormatter.dateFormat = "M/d/yy"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        }
        
        return dateFormatter.string(from: date)
    }
}
