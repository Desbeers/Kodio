///
/// Player.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

extension KodiClient {
    // MARK: - PlayerLists (struct)

    struct PlayerLists {
        var properties = PlayerPropertiesFields()
        var item = PlayerItemFields()
        var playlistItems = 0
        var navigationTitle: String {
            var title = "Kodio"
            if let label = item.title {
                title = label
            }
            return title
        }
        var navigationSubtitle: String {
            var title = "Play your own music"
            if let artist = item.artist?.first, !artist.isEmpty {
                title = artist
            }
            return title
        }
    }

    // MARK: - get the player properties

    func getPlayerProperties(playerItem: Bool = true) {
        let request = PlayerGetProperties()
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result else {
                    return
                }
                self?.player.properties = results
                self?.log(#function, "Got player properties")
                if playerItem {
                    self?.log(#function, "Looking for the item in the player")
                    self?.getPlayerItem()
                }
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }

    // MARK: - get the currently played item

    func getPlayerItem() {
        let request = PlayerGetItem()
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result else {
                    return
                }
                var item = results.item
                /// Swap artist/title if it is not a song
                if results.item.songID == nil {
                    item.artist = [item.label]
                    item.title = nil
                }
                self?.player.item = item
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }

    // MARK: - sendPlaylistAndPlay

    /// - Stop the player
    /// - Clear the playlist
    /// - Fill the playlist with songs
    /// - Start the player
    /// - Update the playlist viewer

    func sendPlaylistAndPlay(songs: [SongFields], shuffled: Bool = false) {
        /// # Don't bother with notifications
        self.notificate = false
        /// # Stop the player
        sendPlayerAction(api: .playerStop)
        /// # Clear the playlist
        sendPlaylistAction(api: .playlistClear)
        /// # Collect the songs to add
        var songList: [Int] = []
        for song in songs {
            songList.append(song.songID)
        }
        /// # Add the songs
        let request = PlaylistAction(method: .playlistAdd, songList: songList)
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success:
                /// # Update the playlist queue
                self?.updatePlaylistQueue()
                /// # Start notifications again
                self?.notificate = true
                /// # Start playing
                self?.sendPlayerAction(api: .playerOpen, playlistPosition: 0, shuffled: shuffled)
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }

    // MARK: sendSongAndPlay (play one song from an album list)

    /// There are a few senario's
    /// - Song is already in the queue -> Jump to the song
    /// - It's a new song, just play it with 'Player.Open"

    func sendSongAndPlay(song: SongFields) {
        if let index = self.playlists.queue.firstIndex(where: { $0.songID == song.songID }) {
            /// Song is in the playlist, let's jump if the player is already playing
            if player.properties.speed == 1 {
                sendPlayerAction(api: .playerGoTo, playlistPosition: playlists.queue[index].playlistID)
            }
            /// Player is stopped; start at the playlist position
            else {
                sendPlayerAction(api: .playerOpen, playlistPosition: playlists.queue[index].playlistID)
            }
        }
        /// Song is not in the playlist; just open it
        else {
            sendPlayerAction(api: .playerOpen, songID: song.songID)
        }
    }

    // MARK: sendPlayerPlayPause (No response needed)

    /// There are a few senario's
    /// - Playlist is paused: - > do play/pause
    /// - Playlist is playing: -> do play/pause
    /// - Playlist is stopped: -> do play playlist
    /// - Playlist is empty: - > disable button

    func sendPlayerPlayPause() {
        if self.player.item.songID == nil && !playlists.queue.isEmpty {
            sendPlayerAction(api: .playerOpen, playlistPosition: 0)
        } else {
            sendPlayerAction(api: .playerPlayPause)
        }
    }

    // MARK: sendPlayerAction (No response needed)

    func sendPlayerAction(
        api: Method,
        playlistPosition: Int = -1,
        songID: Int = -1,
        file: String = "",
        shuffled: Bool = false
    ) {
        let request = PlayerAction(
            method: api,
            playlistPosition: playlistPosition,
            songID: songID,
            file: file,
            shuffled: shuffled
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
}

// MARK: - PlayerAction (API request)

struct PlayerAction: KodiRequest {
    /// Arguments
    var method: Method
    var playlistPosition = -1
    var songID = -1
    var file = ""
    var shuffled: Bool = false
    /// The JSON creator
    var parameters: Data {
        switch method {
        // MARK: Player.PlayPause
        case .playerPlayPause:
            struct PlayPause: Encodable {
                let playerid = 0
            }
            return buildParams(params: PlayPause())

        // MARK: Player.Open
        case .playerOpen:
            struct OpenSong: Encodable {
                var item = Item()
                struct Item: Encodable {
                    var songid = 0
                }
            }
            struct OpenFile: Encodable {
                var item = Item()
                struct Item: Encodable {
                    var file = ""
                }
            }
            struct OpenPlaylist: Encodable {
                var item = Item()
                struct Item: Encodable {
                    var playlistid = 0
                    var position = 0
                }
                var options = Options()
                struct Options: Encodable {
                    var shuffled = false
                }
            }
            /// Open a song
            if songID != -1 {
                var params = OpenSong()
                params.item.songid = songID
                return buildParams(params: params)
            }
            /// Open a file
            if !file.isEmpty {
                var params = OpenFile()
                params.item.file = file
                return buildParams(params: params)
            }
            /// Open a playlist
            if playlistPosition != -1 {
                var params = OpenPlaylist()
                params.item.position = playlistPosition
                params.options.shuffled = shuffled

                return buildParams(params: params)
            }
            /// Should be an unused fallback
            return Data()

        // MARK: Player.Stop
        case .playerStop:
            struct Stop: Encodable {
                let playerid = 0
            }
            return buildParams(params: Stop())

        // MARK: Player.Goto
        case .playerGoTo:
            struct GoTo: Encodable {
                let playerid = 0
                var to = 0
            }
            var params = GoTo()
            params.to = playlistPosition
            return buildParams(params: params)

        // MARK: Player.SetShuffle
        case .playerSetShuffle:
            struct SetShuffle: Encodable {
                let playerid = 0
                let shuffle = "toggle"
            }
            let params = SetShuffle()
            return buildParams(params: params)

        // MARK: Player.SetRepeat
        case .playerSetRepeat:
            // MARK: Player.SetRepeat
            struct SetRepeat: Encodable {
                let playerid = 0
                let repeating = "cycle"
                /// Repeat is a reserved word
                enum CodingKeys: String, CodingKey {
                    case playerid
                    case repeating = "repeat"
                }
            }
            let params = SetRepeat()
            return buildParams(params: params)

        default:
            return Data()
        }
    }
    /// The response struct
    // typealias response = Response
    struct Response: Decodable {
        /// I don't care about the response
    }
}

// MARK: - Player.GetProperties (API request)

struct PlayerGetProperties: KodiRequest {
    /// Method
    var method = Method.playerGetProperties
    /// The JSON creator
    var parameters: Data {
        return buildParams(params: GetProperties())
    }
    /// The request struct
    struct GetProperties: Encodable {
        let playerid = 0
        let properties = ["speed", "position", "shuffled", "repeat", "percentage"]
    }
    /// The response struct
    typealias Response = PlayerPropertiesFields
}

// MARK: - Player.GetItem (API request)

struct PlayerGetItem: KodiRequest {
    /// Method
    var method = Method.playerGetItem
    /// The JSON creator
    var parameters: Data {
        return buildParams(params: GetItem())
    }
    /// The request struct
    struct GetItem: Encodable {
        let playerid = 0
        let properties = PlayerItemFields().properties
    }
    /// The response struct
    struct Response: Decodable {
        var item = PlayerItemFields()
    }
}

// MARK: - PlayerPropertiesFields (struct)

/// The fields for the player

struct PlayerPropertiesFields: Decodable {
    var playlistPosition: Int = -1
    var repeating: String = ""
    var shuffled: Bool = false
    var speed: Int = 0
    var percentage: Double = 0.0
    var repeatingIcon: String {
        /// Standard icon
        var icon = "repeat"
        /// Overrule if needed
        if repeating == "one" {
            icon = "repeat.1"
        }
        return icon
    }
    enum CodingKeys: String, CodingKey {
        case shuffled, speed, percentage
        case playlistPosition = "position"
        case repeating = "repeat"
    }
}

// MARK: - PlayerItemFields (struct)

/// The fields for the player

struct PlayerItemFields: Decodable {
    /// The fields that we ask for
    var properties = ["title", "artist", "thumbnail"]
    /// The fields from above
    var songID: Int?
    var title: String?
    var artist: [String]?
    var label: String = ""
    var thumbnail: String = ""
    var type: String = ""
    enum CodingKeys: String, CodingKey {
        case label, title, artist, thumbnail, type
        case songID = "id"
    }
}
