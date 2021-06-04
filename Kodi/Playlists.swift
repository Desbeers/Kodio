///
/// Playlist.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

extension KodiClient {
    // MARK: - PlaylistLists (struct)

    struct PlaylistLists {
        var queue = [SongFields]()
        var files = [FileFields]()///
        /// TITLE.swift
        /// Kodio
        ///
        /// © 2021 Nick Berendsen
        ///
        var songs = [SongFields]()
        var title: String?
        var queueListID = UUID().uuidString
    }

    struct LibraryJump: Equatable {
        var artistID: Int = 0
        var albumID: Int = 0
        var songID: Int = 0
    }

    func jumpTo( _ item: SongFields) {
        if let index = songs.all.firstIndex(where: { $0.songID == item.songID }) {
            let appState = AppState.shared
            let song = songs.all[index]
            if let index = artists.all.firstIndex(where: { $0.artistID == song.albumArtistID.first }) {
                artists.selected = artists.all[index]
            }
            if let index = albums.all.firstIndex(where: { $0.albumID == song.albumID }) {
                albums.selected = albums.all[index]
            }
            /// Make sure the correct tabs are selected
            appState.tabs.tabArtistGenre = .artists
            appState.tabs.tabSongPlaylist = .songs
            /// Set the correct filters
            filter.albums = .artist
            filter.songs = .album
            /// Trigger the jump
            libraryJump = LibraryJump(artistID: song.albumArtistID.first!, albumID: song.albumID, songID: song.songID)
        }
    }

    // MARK: - get the playlist queue

    func getPlaylistQueue() {
        let request = PlaylistGetItems()
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result.items else {
                    return
                }
                var playlistPosition = 0
                var songlist = [SongFields]()
                for song in results {
                    if let index = self!.songs.all.firstIndex(where: { $0.songID == song.songID }) {
                        var item = self!.songs.all[index]
                        item.playlistID = playlistPosition
                        playlistPosition += 1
                        songlist.append(item)
                    }
                }
                self?.playlists.queue = songlist
                self?.player.playlistItems = playlistPosition - 1
                self?.log(#function, "Playlist queue loaded")
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }

    // MARK: Update the playlist queue

    func updatePlaylistQueue() {
        playlistTimer?.invalidate()
        DispatchQueue.main.async {
            /// Set a timer so the list has time to fill
            self.playlistTimer = Timer.scheduledTimer(
                withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.getPlaylistQueue()
                }
                })
        }
    }

    // MARK: sendPlaylistMove (No response needed)

    /// Kodi has no function Playlist.Move, only Playlist.Swap and that's not what we need
    /// So, we just keep swapping till a file is moved to the new position.
    /// SwiftUI will do the move in the interface so this smelly trick only happens in the background.
    func sendPlaylistMove(fromPosition: Int, toPosition: Int) {
        if fromPosition < toPosition {
            /// Moving down
            for index in stride(from: fromPosition, through: toPosition - 2, by: 1) {
                sendPlaylistAction(api: .playlistSwap, fromPosition: index, toPosition: index + 1)
            }
        } else {
            /// Moving up
            for index in stride(from: fromPosition, through: toPosition + 1, by: -1) {
                sendPlaylistAction(api: .playlistSwap, fromPosition: index, toPosition: index - 1)
            }
        }
        /// Update the queue so we have the correct playlistID's again
        getPlaylistQueue()
    }
    
    // MARK: sendPlaylistAction (No response needed)

    func sendPlaylistAction(
        api: KodiAPI,
        songList: [Int] = [0],
        playlistPosition: Int = -1,
        fromPosition: Int = -1,
        toPosition: Int = -1
    ) {
        let request = PlaylistAction(
            api: api,
            songList: songList,
            playlistPosition: playlistPosition,
            fromPosition: fromPosition,
            toPosition: toPosition
        )
        log(#function, "Send \(api.method())")
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success:
                break
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }

    // MARK: get a list of playlist files

    func getPlaylistFiles() {
        self.library.playlists = false
        let request = FilesGetDirectory(directory: "special://musicplaylists")
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result.files else {
                    return
                }
                self?.library.playlists = true
                self?.playlists.files = results
                self?.log(#function, "Got a list of playlists")
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }

    // MARK: get a list songs in a playlist file

    func getPlaylistSongs(file: FileFields) {
        let appState = AppState.shared
        let request = FilesGetDirectory(directory: file.file)
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result.files else {
                    return
                }
                var songlist = [SongFields]()
                for song in results {
                    if let index = self!.songs.all.firstIndex(where: { $0.songID == song.songID }) {
                        songlist.append(self!.songs.all[index])
                    }
                }
                self?.playlists.songs = songlist
                self?.playlists.title = file.label
                self?.albums.selected = nil
                self?.filter.songs = .playlist
                appState.tabs.tabSongPlaylist = .songs
                self?.log(#function, "Songs from the playlist loaded")
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - PlaylistAction (API request)

struct PlaylistAction: KodiRequest {
    /// Arguments
    var api: KodiAPI
    var songList: [Int] = []
    var stream: String = ""
    var playlistPosition: Int = -1
    var fromPosition: Int = -1
    var toPosition: Int = -1
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        switch api {
        // MARK: Playlist.Clear
        case .playlistClear:
            struct Clear: Encodable {
                let playlistid = 0
            }
            let params = Clear()
            return buildParams(method: method, params: params)

        // MARK: Playlist.Add
        case .playlistAdd:
            /// Add a stream
            if !stream.isEmpty {
                struct Stream: Encodable {
                    var item = File()
                    var playlistid = 0
                    struct File: Encodable {
                        var file = ""
                    }
                }
                var params = Stream()
                params.item.file = stream
                return buildParams(method: method, params: params)
            }
            /// Add an array of songs
            if !songList.isEmpty {
                struct Add: Encodable {
                    var item = [Songs]()
                    var playlistid = 0
                    struct Songs: Encodable {
                        var songid = 0
                    }
                }
                var params = Add()
                for song in songList {
                    params.item.append(Add.Songs(songid: song))
                }
                return buildParams(method: method, params: params)
            }
            return Data()
        // MARK: Playlist.Remove
        case .playlistRemove:
            struct Remove: Encodable {
                var position = 0
                var playlistid = 0
            }
            var params = Remove()
            params.position = playlistPosition
            return buildParams(method: method, params: params)

        // MARK: Playlist.Swap
        case .playlistSwap:
            struct Swap: Encodable {
                var playlistid = 0
                var position1 = 0
                var position2 = 0
            }
            var params = Swap()
            params.position1 = fromPosition
            params.position2 = toPosition
            return buildParams(method: method, params: params)

        default:
            /// Should be an unused fallback
            return Data()
        }
    }
    /// The response struct
    // typealias response = Response
    struct Response: Decodable {
        /// I don't care about the response
    }
}

// MARK: - Playlist.GetItems (API request)

struct PlaylistGetItems: KodiRequest {
    var api: KodiAPI = .playlistGetItems
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        return buildParams(method: method, params: Params())
    }
    // typealias response = Response
    /// The request struct
    struct Params: Encodable {
        let playlistid = 0
    }
    /// The response struct
    struct Response: Decodable {
        let items: [PlaylistFields]
    }
}

// MARK: - PlaylistFields

struct PlaylistFields: Codable, Identifiable, Hashable {
    var id = UUID()
    let songID: Int
}

extension PlaylistFields {
    enum CodingKeys: String, CodingKey {
        case songID = "id"
    }
}
