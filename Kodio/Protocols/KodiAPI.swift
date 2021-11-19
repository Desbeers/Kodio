//
//  KodiAPI.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

/// A protocol to define a Kodi API request
protocol KodiAPI {
    /// The response given by the struct
    associatedtype Response: Decodable
    /// The httpBody for the request
    var parameters: Data { get }
    /// The method to use
    var method: Method { get }
}

extension KodiAPI {
    
    /// Build the JSON parameters
    /// - Returns: `Data` formatted JSON request
    func buildParams<T: Encodable>(params: T) -> Data {
        let parameters = KodiClient.BaseParameters(method: method.rawValue, params: params.self, id: method.rawValue)
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
        let host = AppState.shared.selectedHost
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
