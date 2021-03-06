//
//  LibraryPlaylists.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Playlists
    
    /// A struct will all playlist related items
    struct Playlists {
        /// A array containing all the playlist items in a ``LibraryListItem`` struct
        var files: [LibraryListItem] = []
    }
    
    /// Get all playlist files from the Kodi host
    /// - Returns: True when loaded; else false
    func getPlaylistsFiles() async -> Bool {
        let request = FilesGetDirectory(directory: "special://musicplaylists")
        do {
            var listItems: [LibraryListItem] = []
            let result = try await kodiClient.sendRequest(request: request)
            for playlist in result.files {
                listItems.append(LibraryListItem(
                    title: playlist.label,
                    subtitle: playlist.description,
                    empty: "The playlist '\(playlist.label)' is empty",
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
    
    /// Get the songs of a playlist
    /// - Parameter file: The playlist file
    /// - Returns: An array of song items
    func getPlaylistSongs(file: String) async -> [SongItem] {
        /// The request
        let request = FilesGetDirectory(directory: file)
        /// The list of songs
        var songList = [SongItem]()
        do {
            let result = try await kodiClient.sendRequest(request: request)
            for song in result.files {
                if let item = songs.all.first(where: { $0.songID == song.songID }) {
                    songList.append(item)
                }
            }
            return songList
        } catch {
            print("Error getting playlist \(error)")
            return songList
        }
    }
}
