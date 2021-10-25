//
//  Properties.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiHost {
    
    // MARK: Properties
    
    /// Get the properties of the Kodi host
    func getProperties() async {
        /// Check connection and load the selected Kodi host if not yet done
        let request = ApplicationGetProperties()
        do {
            let result = try await KodiClient.shared.sendRequest(request: request)
            if properties != result {
                logger("Kodi properties changed")
                properties = result
                DispatchQueue.main.async {
                    self.volume = result.volume
                }
            }
        } catch {
            print("Loading Kodi properties failed with error: \(error)")
        }
    }
    
    /// Retrieves the Kodi host properties (Kodi API)
    struct ApplicationGetProperties: KodiAPI {
        /// Method
        var method = Method.applicationGetProperties
        /// The JSON creator
        var parameters: Data {
            return buildParams(params: Params())
        }
        /// The request struct
        struct Params: Encodable {
            let properties = ["volume", "muted", "name", "version", "sorttokens", "language"]
        }
        /// The response struct
        typealias Response = Properties
    }
    
    /// The struct for the Kodi properties
    struct Properties: Codable, Equatable {
        /// Name of the Kodi host
        var name: String = ""
        /// Volume settig of the Kodi host
        var volume: Double = 0
        /// Bool if the sound is muted or not
        var muted: Bool = false
        /// Kodi host version
        var version = Version()
        /// The version struct (major and minor number)
        struct Version: Codable, Equatable {
            var major: Int = 0
            var minor: Int = 0
        }
        /// Computed info string with name and version number
        var info: String {
            if !name.isEmpty {
                return "\(self.name) \(String(self.version.major)).\(String(self.version.minor))"
            }
            return "No Kodi selected"
        }
        /// The coding keys for the Kodi properties
        enum CodingKeys: String, CodingKey {
            case name, version, volume, muted
        }
    }
}
