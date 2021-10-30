//
//  Volume.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    // MARK: Settings

    /// Set a Kodi host setting (Kodi API)
    struct SettingsSetSettingValue: KodiAPI {
        /// Setting name
        var setting: SettingID
        /// Setting value
        var value: Int
        /// Method
        var method: Method = .settingsSetSettingvalue
        /// The JSON creator
        var parameters: Data {
            var params = Params()
            params.setting = setting.rawValue
            params.value = value
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// Setting name
            var setting = ""
            /// Setting value
            var value = 0
        }
        /// The response struct
        struct Response: Decodable { }
    }
    
    /// Kodi host setting ID
    enum SettingID: String {
        /// ReplayGain (off, track or album)
        case musicPlayerReplayGainType = "musicplayer.replaygaintype"
    }
}
