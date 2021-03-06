///
/// Hosts.swift
/// Kodio
///
/// © 2022 Nick Berendsen
///

import Foundation

/// Host related functions
struct Hosts {
    
    /// Get a list of hosts
    /// - Returns: An array of host items
    static func get() -> [HostItem] {
        logger("Get the list of hosts")
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
    static func active(hosts: [HostItem]) -> HostItem {
        logger("Get the active hosts")
        guard let host = hosts.first(where: { $0.selected == true }) else {
            Task {
                await AppState.shared.setState(current: .noHostConfig)
            }
            /// Return default host
            return HostItem()
        }
        return host
    }
    
    /// Switch to a new host
    static func switchHost(selected: HostItem) {
        Task {
            await AppState.shared.setState(current: .none)
            selectHost(selected: selected)
        }
    }
    
    /// Select a host from the list of available hosts and save the selection
    /// - Parameter selected: A struct of the selected host
    static func selectHost(selected: HostItem) {
        var newHostsList = [HostItem]()
        AppState.shared.hosts.enumerated().forEach { index, element in
            var host = AppState.shared.hosts[index]
            host.selected = (element == selected ? true : false)
            newHostsList.append(host)
        }
        self.save(hosts: newHostsList)
        AppState.shared.hosts = newHostsList
        AppState.shared.selectedHost = selected
    }
}

/// The struct of a host item
struct HostItem: Codable, Identifiable, Hashable {
    /// Give it an ID
    var id = UUID()
    /// Description of the host
    var description: String = ""
    /// Icon of the host
    var icon: String = "building.columns"
    /// IP of the host
    var ip: String = ""
    /// Port of the host
    var port: String = "8080"
    /// TCP of the host
    var tcp: String = "9090"
    /// Username of the host
    var username: String = "kodi"
    /// Password of the host
    var password: String = "kodi"
    /// Is this host selected?
    var selected: Bool = false
}
