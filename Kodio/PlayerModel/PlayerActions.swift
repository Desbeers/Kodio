//
//  Action.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Player {
    
    // MARK: - Actions
    
    /// Send a player action to the host
    func sendAction(
        method: Method,
        queueID: Int = -1,
        songID: Int = -1,
        file: String = "",
        shuffled: Bool = false
    ) {
        let action = PlayerAction(
            method: method,
            queueID: queueID,
            songID: songID,
            file: file,
            shuffled: shuffled
        )
        kodiClient.sendMessage(message: action)
    }
    
    /// Send an action to the host (custom Kodi APi)
    struct PlayerAction: KodiAPI {
        /// Arguments
        var method: Method
        var queueID = -1
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
                if queueID != -1 {
                    var params = OpenPlaylist()
                    params.item.position = queueID
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
                params.to = queueID
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
        struct Response: Decodable { }
    }
}
