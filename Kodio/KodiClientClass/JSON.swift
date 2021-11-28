//
//  JSON.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

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
            debugJsonResponse(data: data)
            throw APIError.invalidData
        }
        return decoded.result
    }
    
    /// Send a message to the host, not caring about the response
    /// - Parameter request: The full URL request
    func sendMessage<T: KodiAPI>(
        message: T
    ) {
        urlSession.dataTask(with: message.urlRequest).resume()
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
    
    /// List of possible errors
    enum APIError: Error {
        /// Invalid data
        case invalidData
        /// Unsuccesfull response
        case responseUnsuccessful
    }
    
    /// The sort fields for JSON requests
    struct SortFields: Encodable {
        /// The method
        var method: String = ""
        /// The order
        var order: String = ""
    }

    /// The sort methods for JSON requests
    enum SortMethod: String {
        /// Order descending
        case descending = "descending"
        /// Order ascending
        case ascending = "ascending"
        ///  Order by last played
        case lastPlayed = "lastplayed"
        ///  Order by play count
        case playCount = "playcount"
        ///  Order by year
        case year = "year"
        ///  Order by track
        case track = "track"
        ///  Order by artist
        case artist = "artist"
        ///  Order by title
        case title = "title"
        /// Nicer that using rawValue
        func string() -> String {
            return self.rawValue
        }
    }
    
}
