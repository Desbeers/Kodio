//
//  KodiHostActions.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    // MARK: - SystemAction (API request)
    
    /// Send a system action to Kodi; not caring about the response
    ///
    /// Usage:
    ///
    ///     let request = SystemAction(api: .applicationQuit)
    ///     sendMessage(request: request)
    
    struct SystemAction: KodiAPI {
        /// Arguments
        var method: Method
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable { }
        /// The response struct
        struct Response: Decodable { }
    }
}