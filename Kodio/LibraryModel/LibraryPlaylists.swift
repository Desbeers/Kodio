//
//  LibraryPlaylists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: - Playlists
    
    /// Get a list of playlist files
    func getPlaylists() async -> Bool {
        let request = FilesGetDirectory(directory: "special://musicplaylists")
        do {
            let result = try await KodiClient.shared.sendRequest(request: request)
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
            allPlaylists = listItems
            return true
        } catch {
            print("Loading playlists failed with error: \(error)")
            return false
        }
    }
}
