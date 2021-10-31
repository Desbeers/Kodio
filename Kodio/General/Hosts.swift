///
/// Hosts.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

struct Hosts {
    
    /// Get a list of hosts
    /// - Returns: An array of host items
    static func get() -> [HostItem] {
        if let hosts = Cache.get(key: "MyHosts", as: [HostItem].self, root: true) {
            return hosts
        } else {
            return [HostItem]()
        }
    }
    
    /// Save the host items to disk
    /// - Parameter hosts: The array of host items
    static func save(hosts: [HostItem]) {
        do {
            try Cache.set(key: "MyHosts", object: hosts, root: true)
        } catch {
            logger("Error saving MyHosts")
        }
    }
    
    /// Get the active host from the list of available hosts
    /// - Returns: A stuct with the active host
    static func active() -> HostItem {
        let hosts = self.get()
        guard let host = hosts.first(where: { $0.selected == true }) else {
            let appState: AppState = .shared
            appState.state = .noHostConfig
            appState.alertItem = appState.alertNoHosts
            /// Return default host
            return HostItem()
        }
        return host
    }
    
    /// Select a host from the list of available hosts and save the selection
    /// - Parameter selected: A struct of the selected host
    static func selectHost(selected: HostItem) {
        var newHostsList = [HostItem]()
        KodiClient.shared.hosts.enumerated().forEach { index, element in
            var host = KodiClient.shared.hosts[index]
            host.selected = (element == selected ? true : false)
            newHostsList.append(host)
        }
        self.save(hosts: newHostsList)
        KodiClient.shared.hosts = newHostsList
        Library.shared.resetLibrary()
        KodiClient.shared.selectedHost = selected
    }
}

/// The struct of a host item
struct HostItem: Codable, Identifiable, Hashable {
    var id = UUID()
    var description: String = ""
    var ip: String = ""
    var port: String = "8080"
    var tcp: String = "9090"
    var username: String = "kodi"
    var password: String = "kodi"
    var selected: Bool = false
}
