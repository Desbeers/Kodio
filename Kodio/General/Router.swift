//
//  Router.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import Foundation
import SwiftlyKodiAPI

/// The Router for Kodio navigation
enum Router: Hashable {
    /// Start View
    case start
    /// Library View
    case library
    /// Compilations View
    case compilations
    /// Recently added View
    case recentlyAdded
    /// Most played View
    case mostPlayed
    /// Recently played View
    case recentlyPlayed
    /// Favorites View
    case favorites
    /// Current qeue View
    case playingQueue
    /// Playlist View
    case playlist(file: List.Item.File)
    /// Music videos View
    case musicVideos
    /// Search View
    case search
    /// Music match View
    case musicMatch
    /// Message for an empty View
    var empty: String {
        switch self {
        case .start:
            return "Loading your library"
        case .library:
            return "Your library is empty"
        case .compilations:
            return "You have no compilation albums"
        case .recentlyAdded:
            return "You have no recently added songs"
        case .mostPlayed:
            return "You have no most played songs"
        case .recentlyPlayed:
            return "You have no recently played songs"
        case .favorites:
            return "You have no favorite songs"
        case .playingQueue:
            return "There is nothing in your queue at the moment"
        case .playlist:
            return "The playlist is empty"
        case .musicVideos:
            return "You have no music videos"
        case .search:
            return "Search did not find any results"
        case .musicMatch:
            return "Music Match is not available"
        }
    }
    /// Router item for the Sidebar
    var sidebar: Item {
        switch self {
        case .start:
            return Item(
                title: "Start",
                description: "Loading your library",
                icon: "music.quarternote.3"
            )
        case .library:
            return Item(
                title: "All Music",
                description: "All the music in your library",
                icon: "music.quarternote.3"
            )
        case .compilations:
            return Item(
                title: "Compilations",
                description: "All compilation albums",
                icon: "person.2"
            )
        case .recentlyAdded:
            return Item(
                title: "Recently Added",
                description: "Your recently added songs",
                icon: "star"
            )
        case .mostPlayed:
            return Item(
                title: "Most Played",
                description: "Your most played songs",
                icon: "infinity"
            )
        case .recentlyPlayed:
            return Item(
                title: "Recently Played",
                description: "Your recently played songs",
                icon: "gobackward"
            )
        case .favorites:
            return Item(
                title: "Favorites",
                description: "Your favorite songs",
                icon: "heart"
            )
        case .playingQueue:
            return Item(
                title: "Now Playing",
                description: "The current playlist",
                icon: "list.triangle"
            )
        case .playlist(let file):
            return Item(
                title: file.title,
                description: "Your playlist",
                icon: "music.note.list"
            )
        case .musicVideos:
            return Item(
                title: "Music Videos",
                description: "All the music videos in your library",
                icon: "music.note.tv"
            )
        case .search:
            return Item(
                title: "Search",
                description: "Search Results",
                icon: "magnifyingglass"
            )
        case .musicMatch:
            return Item(
                title: "Music Match",
                description: "Match playcounts and ratings between Kodi and Music",
                icon: "arrow.triangle.2.circlepath"
            )
        }
    }

    /// An item in the sidebar
    struct Item {
        /// The title of the item
        let title: String
        /// The description of the item
        let description: String
        /// The SF symbol of the item
        let icon: String
    }
}
