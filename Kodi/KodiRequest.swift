///
/// KodiRequest.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - KodiRequest (protocol)

protocol KodiRequest {
    /// The response given by the struct
    associatedtype Response: Decodable
    /// The httpBody for the request
    var parameters: Data { get }
    var api: KodiAPI { get }
}

extension KodiRequest {
    /// Build the JSON request
    func buildParams<T: Encodable>(method: String, params: T) -> Data {
        let parameters = BaseParameters(method: method, params: params.self, id: method)
        do {
            return try JSONEncoder().encode(parameters)
        } catch {
            return Data()
        }
    }
}

extension KodiRequest {
    /// Build the URL request
    var urlRequest: URLRequest {
        let host = getSelectedHost()
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

// MARK: - KodiClient (extension)

extension KodiClient {
    
    // MARK: sendRequest (function)

    /// Send a POST request to Kodi
    /// - Parameters:
    ///     - request: A prepared JSON request
    ///     - completion: The response
    /// - Returns: The decoded response

    func sendRequest<T: KodiRequest>(
        request: T,
        completion: @escaping (Result<BaseResponse<T.Response>?, APIError>) -> Void
    ) {
        fetch(with: request.urlRequest, decode: { json -> BaseResponse<T.Response>? in
            guard let result = json as? BaseResponse<T.Response> else {
                return nil
            }
            self.responseAction(request.api)
            return result
        }, completion: completion)
    }

    // MARK: responseAction (function)

    /// Response when a request was succesfull
    ///
    /// - Parameters:
    ///     - action: the method of the request

    func responseAction(_ action: KodiAPI) {
        switch action {
        case .playerPlayPause:
            getPlayerProperties(playerItem: false)
        case .playerSetShuffle:
            getPlayerProperties(playerItem: false)
            getPlaylistQueue()
        case .playerSetRepeat:
            getPlayerProperties(playerItem: false)
        case .playlistAdd, .playlistRemove:
            getPlaylistQueue()
        default:
            break
        }
    }
    
    // MARK: sendMessage (function)
    
    /// Send a message to the host, not caring about the response
    /// - Parameter request: The full URL request
    func sendMessage<T: KodiRequest>(
        request: T
    ) {
        urlSession.dataTask(with: request.urlRequest).resume()
    }
    
}

// MARK: - JSON stuff

/// Base for parameter struct
struct BaseParameters<T: Encodable>: Encodable {
    let jsonrpc = "2.0"
    var method: String
    var params: T
    var id: String
}

/// Base for response struct
struct BaseResponse<T: Decodable>: Decodable {
    var result: T
}

// MARK: - Sort order for Kodi request

/// The sort fields for JSON creation
enum SortFields: String {
    /// Order
    case descending = "descending"
    case ascending = "ascending"
    /// Method
    case lastPlayed = "lastplayed"
    case playCount = "playcount"
    case year = "year"
    case track = "track"
    case artist = "artist"
}

extension SortFields {
    /// Nicer that using rawValue
    func string() -> String {
        return self.rawValue
    }
}
