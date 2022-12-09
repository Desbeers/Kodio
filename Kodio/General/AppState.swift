//
//  AppState.swift
//  Kodio
//
//  Created by Nick Berendsen on 11/08/2022.
//

import Foundation
import SwiftlyKodiAPI

/// The class to observe the Kodio App state
class AppState: ObservableObject {
    /// The shared instance of this AppState class
    static let shared = AppState()
    /// The Kodio settings
    @Published var settings: KodioSettings
    /// The lists of configured hosts
    @Published private(set) var hosts: [Host]
    /// The currently selected host
    @Published private(set) var host: Host?
    /// Items in the sidebar
    @Published var sidebar: [Router.Item] = []
    /// Init the class; get host information
    private init() {
        self.settings = KodioSettings.load()
        self.hosts = Host.getAll()
        self.host = Host.getSelected(hosts: self.hosts)
    }
}

extension AppState {

    /// Check if a sidebar item is visible
    /// - Parameter route: The ``Router``
    /// - Returns: True or False
    func visible(route: Router) -> Bool {
        switch route {
        case .musicVideos:
            return settings.showMusicVideos
        default:
            return true
        }
    }
}

extension AppState {

    /// Update the Kodio settings
    /// - Parameter settings: The ``KodioSettings``
    @MainActor func updateSettings(settings: KodioSettings) {
        KodioSettings.save(settings: settings)
        self.settings = settings
    }
}

extension AppState {

    /// Select a host
    /// - Parameter host: The ``Host``
    @MainActor func selectHost(host: Host) {
        hosts = Host.selectHost(selected: host, hosts: hosts)
        KodiConnector.shared.state = .none
        self.host = host
        Host.save(hosts: hosts)
    }

    /// Add a host
    /// - Parameter host: The ``Host``
    @MainActor func addHost(host: Host) {
        hosts.append(host)
        Host.save(hosts: hosts)
    }

    /// Update a host
    /// - Parameters:
    ///   - old: The old ``Host`` values
    ///   - new: The new ``Host`` values
    /// - Returns: The new ``Host`` if found; else `nil`
    @MainActor func updateHost(old: Host, new: Host) -> Host? {
        if let index = hosts.firstIndex(of: old) {
            hosts[index] = new
            /// If this is the active host, reload it
            if new.status == .selected {
                host = new
            }
            Host.save(hosts: hosts)
            return new
        }
        /// The host was not found
        return nil
    }

    /// Delete a host
    /// - Parameter host: The ``Host``
    @MainActor func deleteHost(host: Host) {
        if let index = hosts.firstIndex(of: host) {
            hosts.remove(at: index)
            Host.save(hosts: hosts)
            /// If this is the active host, make the host nil
            if host.status == .selected {
                self.host = nil
            }
        }
    }
}

extension AppState {

    /// The state of  loading a View
    /// - Note: This `enum` is not used in this `class` but in Views that load items via a `Task`
    enum State {
        /// The Task is loading the items
        case loading
        /// No items where found by the `Task`
        case empty
        /// The `Task` is done and items where found
        case ready
    }
}
