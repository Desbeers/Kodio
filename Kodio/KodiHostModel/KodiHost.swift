//
//  Shared.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation
import Combine

/// The KodiHost class
///
/// This class takes care of:
/// - Getting the properties from the host
/// - Get and set volume
/// - Fiddling with *ReplayGain*
/// - Scanning the library on request
final class KodiHost {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this KodiHost class
    static let shared = KodiHost()
    /// The shared KodiClient class
    let kodiClient = KodiClient.shared
    /// The properties of the Kodi host
    var properties = Properties()
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() { }
}
