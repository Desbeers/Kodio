//
//  AppStateActions.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension AppState {
    
    // MARK: The state of Kodio
    
    /// The states of Kodio
    enum State {
        /// Not connected and no host
        case none
        /// Connected to the Kodi host
        case connectedToHost
        /// Loading the library
        case loadingLibrary
        /// The library is  loaded
        case loadedLibrary
        /// Kodio is sleeping
        case sleeping
        /// Kodio is waking up
        case wakeup
        /// An error when loading the library or a lost of connection
        case failure
        /// Kodio has no host configuration
        case noHostConfig
    }
    
    /// The actions when the  state of Kodio is changed
    /// - Parameter state: the current ``State``
    func action(state: State) {
        switch state {
        case .connectedToHost:
            Library.shared.getLibrary()
        case .loadedLibrary:
            Task(priority: .high) {
                /// Get the properties of the player
                await Player.shared.getProperties()
                /// Get the current item loaded into the player
                await Player.shared.getItem()
                /// Get the song queue
                await Queue.shared.getItems()
                /// Filter the library and view it
                Library.shared.selection = Library.shared.libraryLists.all.first!
                Library.shared.filterAllMedia()
            }
        case .sleeping:
            logger("Kodio sleeping (\(system))")
            KodiClient.shared.disconnectWebSocket()
        case .wakeup:
            logger("Kodio awake (\(system))")
            KodiClient.shared.connectWebSocket()
        default:
            break
        }
    }
}