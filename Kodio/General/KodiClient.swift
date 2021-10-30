//
//  KodiClient.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiClient {
    func connectToHost(host: HostItem) {
        AppState.shared.loadingState = .none
        if !host.ip.isEmpty {
            logger("Connecting to Kodi on \(host.ip)")
            connectWebSocket()
        }
    }
}

/// Connection between this application and the Kodi host
/// - Mostly for JSON stuff
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
    
    // MARK: sendRequest
    
    /// Send a POST request to Kodi
    /// - Parameters:
    ///     - request: A prepared JSON request
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
    
    /// Base for response struct
    struct BaseResponse<T: Decodable>: Decodable {
        var result: T
    }

    // MARK: sendMessage
    
    /// Send a message to the host, not caring about the response
    /// - Parameter request: The full URL request
    func sendMessage<T: KodiAPI>(
        message: T
    ) {
        urlSession.dataTask(with: message.urlRequest).resume()
    }
}

extension KodiClient {
    
    // MARK: APIError
    
    /// List of possible errors
    enum APIError: Error {
        case invalidData
        case responseUnsuccessful
    }
}
