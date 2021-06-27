///
/// KodiHosts.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - Hosts related stuff

func getAllHosts() -> [HostFields] {
    let decoder = JSONDecoder()
    var hosts = [HostFields]()
    if let available = UserDefaults.standard.data(forKey: "KodiHosts") {
        if let decodedHosts = try? decoder.decode([HostFields].self, from: available) {
            hosts = decodedHosts
        }
    }
    return hosts
}

/// Get the selected host from the list of available hosts
func getSelectedHost() -> HostFields {
    var host = HostFields()
    let hosts = getAllHosts()
    if let index = hosts.firstIndex(where: { $0.selected == true }) {
        host = hosts[index]
        saveSelectedHost(host: host)
    }
    return host
}

// MARK: saveAllHosts (function)

/// Save a array of hosts in UserDefaults
/// - Parameter hosts: array of hosts
func saveAllHosts(hosts: [HostFields]) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(hosts) {
        UserDefaults.standard.set(encoded, forKey: "KodiHosts")
    }
}

// MARK: saveSelectedHost (function)

/// Save a array of hosts in UserDefaults
/// - Parameter hosts: array of hosts
func saveSelectedHost(host: HostFields) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(host) {
        UserDefaults.standard.set(encoded, forKey: "KodiHost")
    }
}

extension KodiClient {
    
    // MARK: connectHost (function)
    
    /// Check if there is a connection to the host and then load it.
    func connectHost() {
        /// Check connection and load the selected Kodi host if not yet done
        let request = ApplicationGetProperties()
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let result):
                /// Load the library if we are online and it's not loaded yet
                if self?.library.loaded == false {
                    self?.library.loaded = true
                    self?.log(#function, "Connected to Kodi")
                    if let results = result?.result {
                        self?.properties = results
                    }
                    /// Check if the library is still up to date
                    self?.getAudioLibraryLastUpdate()
                    self?.getLibrary()
                    self?.connectWebSocket()
                    self?.library.online = true
                }
                self?.properties.volume = result?.result.volume ?? 0
                /// While we are here; keep an eye on the player
                self?.getPlayerItem()
            case .failure:
                /// The first timed request after switching hosts gives a failure for no good reason
                if self?.library.switchHost == true {
                    self?.library.switchHost = false
                    break
                }
                /// Disconnect and set defaults
                if self?.library.online == true {
                    self?.disconnectWebSocket()
                    self?.player = PlayerLists()
                    self?.properties = KodiProperties()
                    self?.log(#function, "Kodi is offline")
                    self?.library.reset()
                    self?.library.online = false
                }
            }
        }
    }

    // MARK: selectHost (function)
    
    /// Save the selected host in UserDefaults and load it
    func selectHost(selected: HostFields) {
        var newHostsList = [HostFields]()
        hosts.enumerated().forEach { index, element in
            var host = hosts[index]
            host.selected = (element == selected ? true : false)
            newHostsList.append(host)
        }
        saveSelectedHost(host: selected)
        saveAllHosts(hosts: newHostsList)
        /// Reload Kodio with selected host
        self.properties = KodiProperties()
        self.log(#function, "Loading new Host")
        self.library.reset()
        self.connectHost()
    }
}

// MARK: - Application.GetProperties (API request)

struct ApplicationGetProperties: KodiRequest {
    /// Method
    var api = KodiAPI.applicationGetProperties
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        return buildParams(method: method, params: Params())
    }
    /// The request struct
    struct Params: Encodable {
        let properties = ["volume", "muted", "name", "version", "sorttokens", "language"]
    }
    /// The response struct
    typealias Response = KodiProperties
}

struct KodiProperties: Codable {
    var name: String = ""
    var volume: Double = 0
    var muted: Bool = false
    var version = Version()
    struct Version: Codable {
        var major: Int = 0
        var minor: Int = 0
    }
    var info: String {
        if !name.isEmpty {
            return "\(self.name) \(String(self.version.major)).\(String(self.version.minor))"
        }
        return "No Kodi selected"
    }
}

extension KodiProperties {
    enum CodingKeys: String, CodingKey {
        case name, version, volume, muted
    }
}

// MARK: - HostFields (struct)

/// The fields for a host
struct HostFields: Codable, Identifiable, Hashable {
    var id = UUID()
    var description: String = ""
    var ip: String = ""
    // var ip: String = "127.0.0.10"
    var port: String = "8080"
    var tcp: String = "9090"
    var username: String = ""
    var password: String = ""
    var selected: Bool = false
}
