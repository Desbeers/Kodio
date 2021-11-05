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
        /// A list containing all the playlist files
        var files: [LibraryListItem] = []
        /// A list containng the songs of the selected playlist
        var songs: [SongItem] = []
    }
    
    /// Get all playlist files from the Kodi host
    /// - Returns: True when loaded; else false
    func getPlaylistsFiles() async -> Bool {
        let request = FilesGetDirectory(directory: "special://musicplaylists")
        do {
            var listItems: [LibraryListItem] = []
            /// Random songs
            listItems.append(LibraryListItem(
                title: "Random songs",
                subtitle: "100 random songs from your library",
                icon: "sparkles",
                media: .random
            ))
            /// Never played
            listItems.append(LibraryListItem(
                title: "Never played",
                subtitle: "Songs you never played",
                icon: "minus.diamond",
                media: .neverPlayed
            ))
            let result = try await KodiClient.shared.sendRequest(request: request)
            for playlist in result.files {
                listItems.append(LibraryListItem(
                    title: playlist.label,
                    subtitle: playlist.description,
                    icon: playlist.icon,
                    media: .playlist,
                    file: playlist.file
                    )
                )
            }
            logger("Playlists loaded")
            playlists.files = listItems
            return true
        } catch {
            print("Loading playlists failed with error: \(error)")
            return false
        }
    }
    
    func getPlaylistSongs(file: String) async -> [SongItem] {
        let request = FilesGetDirectory(directory: file)
        var songList = [SongItem]()
        do {
            let result = try await KodiClient.shared.sendRequest(request: request)
            for song in result.files {
                if let item = songs.all.first(where: { $0.songID == song.songID }) {
                    songList.append(item)
                }
            }
            return songList
        } catch {
            print(error)
            return songList
        }
    }
}
