//
//  Hosts.swift
//  Kodio
//
//  Created by Nick Berendsen on 09/08/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The struct for a Kodi host
struct Host: Codable, Identifiable, Hashable {
    /// Give it an ID
    var id: String { details.ip }
    /// Host details
    var details = HostItem()
    /// Icon of the host
    var icon: String = "building.columns"
    /// The status of the host
    var status: Status = .new
    /// The color for the icon
    var color: Color {
        switch status {
        case .new:
            return .accentColor
        default:
            return details.isOnline ? .green : .red
        }
    }
    /// The status of the host
    enum Status: String, Codable {
        case new
        case configured
        case selected
    }
}

extension Host {

    /// Get the active host
    /// - Parameter hosts: The list of hosts
    /// - Returns: An optional ``Host``
    static func getSelected(hosts: [Host]) -> Host? {
        if let selected = hosts.first(where: {$0.status == .selected}) {
            return selected
        }
        return nil
    }

    /// Get all configured hosts
    /// - Returns: An array of ``Host``
    static func getAll() -> [Host] {
        logger("Get the list of hosts")
        if let hosts = Cache.get(key: "MyHosts", as: [Host].self, root: true) {
            return hosts
        }
        /// No hosts found
        return [Host]()
    }

    /// Save the hosts to the cache
    /// - Parameter hosts: The array of hosts
    static func save(hosts: [Host]) {
        do {
            try Cache.set(key: "MyHosts", object: hosts, root: true)
        } catch {
            logger("Error saving MyHosts")
        }
    }

    /// Mark a host as active in the hosts list
    /// - Parameters:
    ///   - selected: The ``Host`` to make as active
    ///   - hosts: The array of hosts
    /// - Returns: A new array of hosts
    static func selectHost(selected: Host, hosts: [Host]) -> [Host] {
        var newHostsList = [Host]()
        hosts.enumerated().forEach { index, element in
            var host = hosts[index]
            host.status = (element == selected ? Host.Status.selected : Host.Status.configured)
            newHostsList.append(host)
        }
        return newHostsList
    }
}
