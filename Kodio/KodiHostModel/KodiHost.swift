//
//  Shared.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation
import Combine

// MARK: - KodiHost model

/// KodiHost model
class KodiHost: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this KodiHost class
    static let shared = KodiHost()
    /// The shared KodiClient class
    let kodiClient = KodiClient.shared
    /// The properties of the Kodi host
    var properties = Properties()
    /// The volume of the Kodi host; published because it is used in a Swift View
    @Published var volume: Double = 0
    /// Init the class
    private init() {
        /// Get the properties of the Kodi host
        Task {
            await getProperties()
        }
    }
}
