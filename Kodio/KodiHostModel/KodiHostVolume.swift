//
//  Volume.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    // MARK: Volume
    
    /// Set the host volume
    /// - Parameter volume: value between 0 and 100
    func setVolume(volume: Double) {
        logger("Set volume")
        let message = SetVolume(volume: volume)
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
            var volume: Int = 0
        }
        /// The response struct
        struct Response: Decodable { }
    }
}
