//
//  MusicMatchModel+Structs.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

#if os(macOS)

import Foundation
import SwiftlyKodiAPI

extension MusicMatchModel {

    /// A Music Match Item
    struct Item: Codable, Identifiable, Equatable {
        /// The ID of the Kodi Song
        var id: Library.ID
        /// The title of the song
        var title: String
        /// The album title of the song
        var album: String
        /// The artist of the song
        var artist: String
        /// The track number of the song
        var track: Int
        /// Bool if Kodi song is matched with Music
        var matched: Bool = false
        /// Kodi values
        var kodi = Values()
        /// Music values
        var music = Values()
        /// Sync values
        var sync = Values()

        /// # Calculated stuff

        /// Bool if the item is in sync or not
        var itemInSync: Bool {
            self.kodi == self.sync && self.music == self.sync && self.matched == true
        }
    }

    /// The sync values of an Item (Kodi or Music song)
    struct Values: Codable, Equatable {
        /// The playcount of the item
        var playcount: Int = 0
        /// The last played daye as String
        var lastPlayed: String = "2000-01-01 00:00:00"
        /// The rating of the item
        var rating: Int = 0
    }
}

extension MusicMatchModel {

    /// Progress values of matching
    struct Progress {
        /// Total number of songs
        var total: Double = 0
        /// Current song number
        var current: Double = 0
    }
}

#endif
