//
//  PlayPause.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Player {
    
    // MARK: Player buttons
    
    /// Play or pause the player
    ///
    /// There are a few senario's:
    /// - Playlist is paused: - > do method .playerPlayPause
    /// - Playlist is playing: -> do method .playerPlayPause
    /// - Playlist is stopped: -> do method .playerOpen
    func playPause() async {
        if properties.queueID == -1 && !queueEmpty {
            sendAction(method: .playerOpen, queueID: 0)
        } else {
            sendAction(method: .playerPlayPause)
        }
    }
    
    /// Play next item in the player
    func playNext() async {
        sendAction(method: .playerGoTo, queueID: properties.queueID + 1)
    }

    /// Play previous item in the player
    func playPrevious() async {
        sendAction(method: .playerGoTo, queueID: properties.queueID - 1)
    }
    
    /// Play a specific ``Library/SongItem``
    ///
    /// There are a few senario's:
    /// - Song is already in the queue -> Jump to the song in the queue
    /// - It's a new song -> Send the song to ``playAllSongs`` to play it in a new playlist
    ///
    /// - Parameter song: A ``Library/SongItem``
    func playSong(song: Library.SongItem) async {
        let queueSongs = Library.shared.getSongsFromQueue()
        if let index = queueSongs.firstIndex(where: { $0.songID == song.songID }) {
            /// Song is in the playlist, let's jump if the player is already playing
            if properties.speed == 1 {
                sendAction(method: .playerGoTo, queueID: queueSongs[index].queueID)
            }
            /// Player is stopped; start at the playlist position
            else {
                sendAction(method: .playerOpen, queueID: queueSongs[index].queueID)
            }
        }
        /// Song is not in the playlist; just open it in a new playlist
        else {
            await playPlaylist(songs: [song], album: false)
        }
    }
    
    /// Play an array of ``Library/SongItem``s in a new playlist
    ///
    /// - Clear the playlist
    /// - Fill the playlist with new songs
    /// - Open the player
    ///
    /// - Parameters:
    ///   - songs: A array of``Library/SongItem``s
    ///   - album: ``Bool`` if this is an album or not; it will set ReplayGain
    ///   - shuffled: ``Bool`` if the playlist must be shuffled or not
    func playPlaylist(songs: [Library.SongItem], album: Bool, shuffled: Bool = false) async {
        /// Clear the queue playlist
        Queue.shared.sendAction(method: .playlistClear)
        /// Disable party mode if needed
        if properties.partymode {
            await togglePartyMode()
        }
        /// Set the ReplayGain setting
        await KodiHost.shared.setReplayGain(mode: album ? .album : .track)
        /// Collect the songs to add
        var songList: [Int] = []
        for song in songs {
            songList.append(song.songID)
        }
        let request = Queue.QueueAction(method: .playlistAdd, songList: songList)
        /// Add the songs and open the player
        Task {
            do {
                _ = try await kodiClient.sendRequest(request: request)
                /// Start playing
                sendAction(method: .playerOpen, queueID: 0, shuffled: shuffled)
            } catch {
                print(error)
            }
        }
    }

    /// Update a playlist
    ///
    /// This will be called after reordering or deleting a song in the player queue
    /// - Parameter songs: The current songs in the player queue
    func updatePlaylist(songs: [Library.SongItem]) async {
        logger("Update playlist")
        /// Clear the queue playlist
        Queue.shared.sendAction(method: .playlistClear)
        /// Collect the songs to add
        var songList: [Int] = []
        for song in songs {
            songList.append(song.songID)
        }
        /// Disable shuffle if needed
        if properties.shuffled {
            await toggleShuffle()
        }
        /// Send the new queue list
        let request = Queue.QueueAction(method: .playlistAdd, songList: songList)
        Task {
            do {
                _ = try await kodiClient.sendRequest(request: request)
                /// Send a notification that we have a new queue
                /// - Note: self-send notification will be ignored; the list is already updated by the queue view
                await kodiClient.sendNotification(message: "NewQueue")
            } catch {
                print(error)
            }
        }
    }
    
    /// Play a radio station
    /// - Parameter stream: the audio stream to play
    func playRadio(stream: String) async {
        /// Disable party mode if needed
        if properties.partymode {
            await togglePartyMode()
        }
        let request = Queue.QueueAction(method: .playlistAdd, stream: stream)
        Task {
            do {
                Queue.shared.sendAction(method: .playlistClear)
                _ = try await kodiClient.sendRequest(request: request)
                /// # Start playing
                Player.shared.sendAction(method: .playerOpen, queueID: 0)
            } catch {
                print(error)
            }
        }
    }
    
    /// Toggle the 'repeat' button of the player
    func toggleRepeat() async {
        sendAction(method: .playerSetRepeat)
    }
    
    /// Toggle the 'shuffle' button of the player
    func toggleShuffle() async {
        sendAction(method: .playerSetShuffle)
    }

    /// Toggle the 'party mode' button of the player
    func togglePartyMode() async {
        /// Set ReplayGain to 'tracks' if we start Party Mode
        if !properties.partymode {
            await KodiHost.shared.setReplayGain(mode: .track)
        }
        sendAction(method: .playerSetPartymode)
    }
    
    /// Set the host volume
    ///
    /// - I put this in the ``Player`` class because I think thats a logic place
    ///
    /// - Parameter volume: value between 0 and 100
    func setVolume(volume: Double) async {
        await KodiHost.shared.setVolume(volume: volume)
    }
    
    /// Toggle the mute on  the host
    func toggleMute() async {
        await KodiHost.shared.toggleMute()
    }
}
