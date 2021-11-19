//
//  QueueActions.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Queue {
    
    // MARK: sendAction
    
    /// Send an action to Kodi; not caring about the response
    /// - Parameters:
    ///   - method: The method to use
    ///   - songList: An array of song ID's
    ///   - playlistPosition: Position in the playlist
    ///   - fromPosition: Move an item in the queue, start position
    ///   - toPosition: Move an item in the queue, end position
    func sendAction(
        method: Method,
        songList: [Int] = [0],
        playlistPosition: Int = -1,
        fromPosition: Int = -1,
        toPosition: Int = -1
    ) {
        let action = QueueAction(
            method: method,
            songList: songList,
            playlistPosition: playlistPosition,
            fromPosition: fromPosition,
            toPosition: toPosition
        )
        kodiClient.sendMessage(message: action)
    }
    
    /// Send an action to the host (custom Kodi APi)
    struct QueueAction: KodiAPI {
        /// The method
        var method: Method
        /// List of song ID's
        var songList: [Int] = []
        /// A stream to open
        var stream: String = ""
        /// The position in the playlist
        var playlistPosition: Int = -1
        /// Start position when moving an item
        var fromPosition: Int = -1
        /// End position when moving an item
        var toPosition: Int = -1
        /// The JSON creator
        var parameters: Data {
            switch method {
            case .playlistClear:
                // MARK: Playlist.Clear
                /// Struct for Clear
                struct Clear: Encodable {
                    /// The ID of the playlist
                    let playlistid = 0
                }
                /// The parameters
                let params = Clear()
                return buildParams(params: params)
            case .playlistAdd:
                // MARK: Playlist.Add
                /// Add a stream
                if !stream.isEmpty {
                    /// The struct for Stream
                    struct Stream: Encodable {
                        /// The stream name
                        var item = File()
                        /// The ID of the playlist
                        var playlistid = 0
                        /// The struct for File
                        struct File: Encodable {
                            var file = ""
                        }
                    }
                    /// The parameters
                    var params = Stream()
                    params.item.file = stream
                    return buildParams(params: params)
                }
                /// Add an array of songs
                if !songList.isEmpty {
                    /// The struct for Add
                    struct Add: Encodable {
                        /// The array with song ID's
                        var item = [Songs]()
                        /// The ID of the playlist
                        var playlistid = 0
                        /// The struct for Songs
                        struct Songs: Encodable {
                            /// The ID of the song
                            var songid = 0
                        }
                    }
                    /// The parameters
                    var params = Add()
                    for song in songList {
                        params.item.append(Add.Songs(songid: song))
                    }
                    return buildParams(params: params)
                }
                return Data()
            case .playlistRemove:
                // MARK: Playlist.Remove
                /// The struct for Remove
                struct Remove: Encodable {
                    /// Position of the item to remove
                    var position = 0
                    /// The playlist ID
                    var playlistid = 0
                }
                /// The parameters
                var params = Remove()
                params.position = playlistPosition
                return buildParams(params: params)
            case .playlistSwap:
                // MARK: Playlist.Swap
                /// The struct for Swap
                struct Swap: Encodable {
                    /// The playlist ID
                    var playlistid = 0
                    /// Start position
                    var position1 = 0
                    /// End position
                    var position2 = 0
                }
                /// The parameters
                var params = Swap()
                params.position1 = fromPosition
                params.position2 = toPosition
                return buildParams(params: params)
            default:
                // MARK: default
                /// Should be an unused fallback
                return Data()
            }
        }
        /// The response struct
        struct Response: Decodable { }
    }
}
