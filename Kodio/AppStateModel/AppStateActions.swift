//
//  AppStateActions.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension AppState {
    
    // MARK: The state of Kodio

    /// Update the sidebar
    @MainActor func updateSidebar() async {
        let library: Library = .shared
        let list = library.getLibraryLists()
        /// Check the selected item
        if let selected = list.first(where: { $0.media == library.selection.media}) {
            if selected.visible {
                /// Update the selection
                library.selection = selected
                sidebarSelection = selected
            } else {
                /// Select the first item in the sidebar
                await library.selectLibraryList(libraryList: list.first!)
            }
        }
        logger("Update sidebar")
        sidebarItems = library.getLibraryLists()
    }
    
    /// Set the state of Kodio and act on it
    @MainActor func setState(current: State) {
        logger("Kodio status: \(current.rawValue)")
        state = current
        DispatchQueue.global(qos: .background).async {
            self.action(state: current)
        }
    }
    
    /// The state of Kodio
    enum State: String {
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
    private func action(state: State) {
        switch state {
        case .connectedToHost:
            /// Reset library and set the selection with the new host information
            Library.shared.resetLibrary(host: selectedHost)
            Task {
                await KodiHost.shared.getProperties()
            }
            Library.shared.getLibrary()
        case .loadedLibrary:
            Task(priority: .high) {
                /// Get the properties of the player
                await Player.shared.getProperties()
                /// Get the current item loaded into the player
                await Player.shared.getItem()
                /// Get the song queue
                await Queue.shared.getItems()
                /// Update the sidebar
                await updateSidebar()
                /// Filter the library and view it if we are just starting
                if Library.shared.selection.media == .none {
                    await Library.shared.selectLibraryList(libraryList: Library.shared.libraryLists.all.first!)
                }
            }
        case .sleeping:
            logger("Kodio sleeping (\(system))")
            kodiClient.disconnectWebSocket()
        case .wakeup:
            logger("Kodio awake (\(system))")
            kodiClient.connectWebSocket()
        case .failure:
            Task {
                await viewAlert(type: .hostNotAvailable)
            }
        case .noHostConfig:
            Task {
                await viewAlert(type: .noHosts)
            }
        default:
            break
        }
    }
}
