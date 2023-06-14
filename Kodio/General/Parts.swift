//
//  Parts.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import Foundation

/// Shared bits and pieces
enum Parts {
    // Just a namespace here
}

extension Parts {

    /// Convert a `Date` to a Kodi date string
    /// - Parameter date: The `Date`
    /// - Returns: A string with the date
    static func kodiDateFromSwiftDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        /// It turns out that the DateFormatter takes the target date into account, not our current time, which is not what we want so set the the zone
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        return dateFormatter.string(from: date)
    }

    /// Convert a Kodi date string to a `Date`
    /// - Parameter date: The Kodi date string
    /// - Returns: A Swift `Date`
    static func swiftDateFromKodiDate(_ date: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        /// It turns out that the DateFormatter takes the target date into account, not our current time, which is not what we want so set the the zone
        dateFormatter.timeZone = TimeZone(secondsFromGMT: TimeZone.current.secondsFromGMT())
        return dateFormatter.date(from: date) ?? Date(timeIntervalSinceReferenceDate: 0)
    }
}
