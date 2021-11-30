//
//  Action.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Player {
    
    // MARK: Actions
    
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
        /// The method
        var method: Method
        /// Queue ID
        var queueID = -1
        /// Song ID
        var songID = -1
        /// File name
        var file = ""
        /// Shuffle
        var shuffled: Bool = false
        /// The JSON creator
        var parameters: Data {
            switch method {
                // MARK: Player.PlayPause
            case .playerPlayPause:
                /// Struct for Play/Pause
                struct PlayPause: Encodable {
                    /// The player ID
                    let playerid = 0
                }
                return buildParams(params: PlayPause())
                
                // MARK: Player.Open
            case .playerOpen:
                /// Struct for OpenSong
                struct OpenSong: Encodable {
                    /// Item to open
                    var item = Item()
                    /// Struct for Item
                    struct Item: Encodable {
                        /// Song ID
                        var songid = 0
                    }
                }
                /// Struct for OpenFile
                struct OpenFile: Encodable {
                    /// Item to open
                    var item = Item()
                    struct Item: Encodable {
                        /// Name of the file
                        var file = ""
                    }
                }
                /// Struct for OpenPlaylist
                struct OpenPlaylist: Encodable {
                    /// Item to open
                    var item = Item()
                    struct Item: Encodable {
                        /// The playlist ID
                        var playlistid = 0
                        /// Position in the playlist
                        var position = 0
                    }
                    /// Options for OpenPlaylist
                    var options = Options()
                    /// The struct for options
                    struct Options: Encodable {
                        /// Shuffle or not
                        var shuffled = false
                    }
                }
                /// Open a song
                if songID != -1 {
                    /// The parameters
                    var params = OpenSong()
                    params.item.songid = songID
                    return buildParams(params: params)
                }
                /// Open a file
                if !file.isEmpty {
                    /// The parameters
                    var params = OpenFile()
                    params.item.file = file
                    return buildParams(params: params)
                }
                /// Open a playlist
                if queueID != -1 {
                    /// The parameters
                    var params = OpenPlaylist()
                    params.item.position = queueID
                    params.options.shuffled = shuffled
                    return buildParams(params: params)
                }
                /// Should be an unused fallback
                return Data()
                
                // MARK: Player.Stop
            case .playerStop:
                /// Struct for Stop
                struct Stop: Encodable {
                    /// The player ID
                    let playerid = 0
                }
                return buildParams(params: Stop())
                
                // MARK: Player.Goto
            case .playerGoTo:
                /// Struct for GoTo
                struct GoTo: Encodable {
                    /// The player ID
                    let playerid = 0
                    /// The number to go to
                    var to = 0
                }
                /// The parameters
                var params = GoTo()
                params.to = queueID
                return buildParams(params: params)
                
                // MARK: Player.SetShuffle
            case .playerSetShuffle:
                /// Struct for SetShuffle
                struct SetShuffle: Encodable {
                    /// The player ID
                    let playerid = 0
                    /// Toggle the shuffle
                    let shuffle = "toggle"
                }
                /// The parameters
                let params = SetShuffle()
                return buildParams(params: params)
                
                // MARK: Player.SetPartymode
            case .playerSetPartymode:
                /// Struct for SetPartymode
                struct SetPartymode: Encodable {
                    /// The player ID
                    let playerid = 0
                    /// Toggle the party mode
                    let partymode = "toggle"
                }
                /// The parameters
                let params = SetPartymode()
                return buildParams(params: params)
                
                // MARK: Player.SetRepeat
            case .playerSetRepeat:
                /// Struct for SetRepeat
                struct SetRepeat: Encodable {
                    /// The player ID
                    let playerid = 0
                    /// Cycle trough repeating modus
                    let repeating = "cycle"
                    /// Coding keys
                    /// - Note: Repeat is a reserved word
                    enum CodingKeys: String, CodingKey {
                        /// The key
                        case playerid
                        /// Repeat is a reserved word
                        case repeating = "repeat"
                    }
                }
                /// The parameters
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
