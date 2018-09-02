//
//  DateUtils.swift
//  Flokk
//
//  Created by Gannon Prudhomme on 8/30/18.
//  Copyright © 2018 Gannon Prudomme. All rights reserved.
//

import Foundation

class DateUtils {
    static func getDate(timestamp: Double) -> String {
        let date = Date(timeIntervalSinceReferenceDate: timestamp)
        
        let dateFormatter = DateFormatter()
        
        //DateFormatter.dateFormat(fromTemplate: "dd-MM HH:mm", options: 0, locale: Locale.current)
        dateFormatter.dateFormat = "MM-dd H:mm a"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        
        return dateFormatter.string(from: date)
    }
}
