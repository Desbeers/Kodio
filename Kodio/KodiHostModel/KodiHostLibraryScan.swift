//
//  KodiHostActions.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    /// Tell Kodi to rescan the audio database
    func scanAudioLibrary() {
        let message = SystemAction(method: .audioLibraryScan)
        kodiClient.sendMessage(message: message)
    }
}
