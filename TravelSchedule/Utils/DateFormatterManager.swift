//
//  DateFormatterManager.swift
//  TravelSchedule
//

import Foundation

enum DateFormatterManager {
    static let dateYMD: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "ru_RU")
        f.timeZone = .current
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    
    static let iso8601: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        f.timeZone = TimeZone(secondsFromGMT: 0)
        return f
    }()
    
    static let hhmm: DateFormatter = {
        let f = DateFormatter()
        f.calendar = .init(identifier: .gregorian)
        f.locale = .init(identifier: "ru_RU")
        f.timeZone = .current
        f.dateFormat = "HH:mm"
        return f
    }()
}
