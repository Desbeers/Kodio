//
//  Volume.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    // MARK: Volume
    
    /// Set the host volume
    /// - Parameter volume: value between 0 and 100
    func setVolume(volume: Double) async {
        logger("Set volume")
        let message = SetVolume(volume: volume)
        kodiClient.sendMessage(message: message)
    }
    
    /// Toggle the mute on  the host
    func toggleMute() async {
        logger("Toggle mute")
        let message = ToggleMute()
        kodiClient.sendMessage(message: message)
    }
    
    /// Set the current volume (Kodi API)
    struct SetVolume: KodiAPI {
        /// Arguments
        var volume: Double
        // Method
        var method: Method = .applicationSetVolume
        /// The JSON creator
        var parameters: Data {
            var params = Params()
            params.volume = Int(volume)
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// Volume
            var volume: Int = 0
        }
        /// The response struct
        struct Response: Decodable { }
    }
    
    /// Toggle the mute (Kodi API)
    struct ToggleMute: KodiAPI {
        // Method
        var method: Method = .applicationSetMute
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            /// Toggle the mute
            let mute = "toggle"
        }
        /// The response struct
        struct Response: Decodable { }
    }
}
