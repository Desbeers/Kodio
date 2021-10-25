//
//  QueueActions.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Queue {
    
    // MARK: sendAction (No response needed)

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
        /// Arguments
        var method: Method
        var songList: [Int] = []
        var stream: String = ""
        var playlistPosition: Int = -1
        var fromPosition: Int = -1
        var toPosition: Int = -1
        /// The JSON creator
        var parameters: Data {
            switch method {
            // MARK: Playlist.Clear
            case .playlistClear:
                struct Clear: Encodable {
                    let playlistid = 0
                }
                let params = Clear()
                return buildParams(params: params)

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
                    return buildParams(params: params)
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
                    return buildParams(params: params)
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
                return buildParams(params: params)

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
                return buildParams(params: params)

            default:
                /// Should be an unused fallback
                return Data()
            }
        }
        /// The response struct
        struct Response: Decodable { }
    }
}
