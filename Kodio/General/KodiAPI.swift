///
/// KodiAPI.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - KodiAPI (protocol)

protocol KodiAPI {
    /// The response given by the struct
    associatedtype Response: Decodable
    /// The httpBody for the request
    var parameters: Data { get }
    var method: Method { get }
}

extension KodiAPI {
    /// Build the JSON request
    func buildParams<T: Encodable>(params: T) -> Data {
        let parameters = BaseParameters(method: method.rawValue, params: params.self, id: method.rawValue)
        do {
            return try JSONEncoder().encode(parameters)
        } catch {
            return Data()
        }
    }
}

extension KodiAPI {
    /// Build the URL request
    var urlRequest: URLRequest {
        let host = KodiClient.shared.selectedHost
        var request = URLRequest(
            url: URL(string: "http://\(host.username):\(host.password)@\(host.ip):\(host.port)/jsonrpc")!
        )
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters
        return request
    }
}

// MARK: - JSON stuff

/// Base for parameter struct
private struct BaseParameters<T: Encodable>: Encodable {
    let jsonrpc = "2.0"
    var method: String
    var params: T
    var id: String
}

// MARK: - Sort order for Kodi request

/// The sort fields for JSON creation

struct SortFields: Encodable {
    var method: String = ""
    var order: String = ""
}

enum SortMethod: String {
    /// Order
    case descending = "descending"
    case ascending = "ascending"
    /// By
    case lastPlayed = "lastplayed"
    case playCount = "playcount"
    case year = "year"
    case track = "track"
    case artist = "artist"
    case title = "title"
}

extension SortMethod {
    /// Nicer that using rawValue
    func string() -> String {
        return self.rawValue
    }
}
