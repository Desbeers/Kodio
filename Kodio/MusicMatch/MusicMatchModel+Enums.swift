//
//  MusicMatchModel+Enums.swift
//  Kodio
//
//  Created by Nick Berendsen on 23/04/2023.
//

import Foundation

extension MusicMatchModel {

    /// The status of song matching
    enum Status: String {
        /// Not loaded
        case none = "Ready to match your songs between Kodi and Music"
        /// Match the Kodi songs with music
        case musicMatching = "Matching songs between Kodi and Music"
        /// Kodi songs are matched with Music
        case musicMatched = "Matched songs between Kodi and Music"
        /// Sync all songs
        case syncAllSongs = "Syncing your songs"
        /// Bool if Music Match is busy
        var busy: Bool {
            self == .musicMatching || self == .syncAllSongs
        }
    }

    /// Which rating to use for syncing
    enum RatingAction: String, CaseIterable {
        /// Use the ratings from Kodi
        case useKodiRating = "Use Kodi Ratings"
        /// Use the ratings from Music
        case useMusicRating = "Use Music Ratings"
        /// Use the highest rating
        case useHighestRation = "Use Highest Rating"
    }

    /// Which playcount to use for syncing
    enum PlaycountAction: String, CaseIterable {
        /// Use the playcount from Kodi
        case useKodiPlaycount = "Use Kodi Playcount"
        /// Use the playcount from Music
        case useMusicPlaycount = "Use Music Playcount"
        /// Use the highest playcount
        case useHighestPlaycount = "Use Highest Playcount"
        /// Use the total playcount
        case useTotalPlaycount = "Use Total Playcount"
    }
}
