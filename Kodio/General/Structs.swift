//
//  Structs.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//
// - MARK: General structs used in several places

import Foundation

// MARK: JSON stuff

/// Base for JSON parameter struct
struct BaseParameters<T: Encodable>: Encodable {
    /// The JSON version
    let jsonrpc = "2.0"
    /// The Kodi method to use
    var method: String
    /// The parameters
    var params: T
    /// The ID
    var id: String
}

// MARK: Sort order for Kodi request

/// The sort fields for JSON creation
struct SortFields: Encodable {
    /// The method
    var method: String = ""
    /// The order
    var order: String = ""
}

/// The available methods
enum SortMethod: String {
    /// Order descending
    case descending = "descending"
    /// Order ascending
    case ascending = "ascending"
    ///  Order by last played
    case lastPlayed = "lastplayed"
    ///  Order by play count
    case playCount = "playcount"
    ///  Order by year
    case year = "year"
    ///  Order by track
    case track = "track"
    ///  Order by artist
    case artist = "artist"
    ///  Order by title
    case title = "title"
}

extension SortMethod {
    /// Nicer that using rawValue
    func string() -> String {
        return self.rawValue
    }
}
