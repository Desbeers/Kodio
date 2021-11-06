//
//  KodiClient.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiClient {

}

/// Connection between Kodio and the Kodi host
class KodiClient: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this KodiClient class
    static let shared = KodiClient()
    /// The URL session
    let urlSession: URLSession
    /// The WebSocket task
    var webSocketTask: URLSessionWebSocketTask?
    /// Bool to turn notifications on and off
    var notificate = true
    /// An array with all Kodi hosts
    @Published var hosts: [HostItem]
    /// A struct with selected host information
    @Published var selectedHost = HostItem() {
        didSet {
            connectToHost(host: selectedHost)
        }
    }
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init(configuration: URLSessionConfiguration) {
        /// Network stuff
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 300
        configuration.timeoutIntervalForResource = 120
        self.urlSession = URLSession(configuration: configuration)
        self.hosts = Hosts.get()
        self.selectedHost = Hosts.active()
    }
    /// Black magic
    convenience init() {
        self.init(configuration: .ephemeral)        
    }
}

extension KodiClient {
    
    // MARK: JSON stuff
    
    /// Send a POST request to Kodi
    /// - Parameter request: A prepared JSON request
    /// - Returns: The decoded response
    func sendRequest<T: KodiAPI>(request: T) async throws -> T.Response {
        let (data, response) = try await urlSession.data(for: request.urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
                  throw APIError.responseUnsuccessful
              }
        guard let decoded = try? JSONDecoder().decode(BaseResponse<T.Response>.self, from: data) else {
            throw APIError.invalidData
        }
        return decoded.result
    }
    
    /// Base for JSON parameter struct
    struct BaseParameters<T: Encodable>: Encodable {
        /// The JSON version
        let jsonrpc = "2.0"
        /// The Kodi method to use
        var method: String
        /// The parameters
        var params: T
        /// The ID
        var id: String
    }
    
    /// Base for response struct
    struct BaseResponse<T: Decodable>: Decodable {
        /// The result variable of a response
        var result: T
    }
    
    /// Send a message to the host, not caring about the response
    /// - Parameter request: The full URL request
    func sendMessage<T: KodiAPI>(
        message: T
    ) {
        urlSession.dataTask(with: message.urlRequest).resume()
    }
    
    /// List of possible errors
    enum APIError: Error {
        /// Invalid data
        case invalidData
        /// Unsuccesfull response
        case responseUnsuccessful
    }
}
