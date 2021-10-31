//
//  LibraryPlaylists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Playlists
    
    /// A struct will all genre related items
    struct Playlists {
        /// A list containing all the playlists
        var all: [SmartListItem] = []
        /// A list containng the songs of the selected playlist
        var songs: [SongItem] = []
    }
    
    /// Get all playlists from the Kodi host
    /// - Returns: True when loaded; else false
    func getPlaylists() async -> Bool {
        let request = FilesGetDirectory(directory: "special://musicplaylists")
        do {
            var listItems: [SmartListItem] = []
            /// Random songs
            listItems.append(SmartListItem(
                title: "Random songs",
                subtitle: "100 random songs from your library",
                icon: "sparkles",
                media: .random
            ))
            /// Never played
            listItems.append(SmartListItem(
                title: "Never played",
                subtitle: "Songs you never played",
                icon: "minus.diamond",
                media: .neverPlayed
            ))
            let result = try await KodiClient.shared.sendRequest(request: request)
            for playlist in result.files {
                listItems.append(SmartListItem(
                    title: playlist.label,
                    subtitle: playlist.description,
                    icon: playlist.icon,
                    media: .playlist,
                    file: playlist.file
                    )
                )
            }
            logger("Playlists loaded")
            playlists.all = listItems
            return true
        } catch {
            print("Loading playlists failed with error: \(error)")
            return false
        }
    }
}
