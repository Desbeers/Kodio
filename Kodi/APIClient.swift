///
/// APIClient.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///
/// This file is very much inspired by
/// https://github.com/jamesrochabrun/ProtocolBasedNetworking
/// I'm not exacly sure what's going on here
///

import Foundation

// MARK: - APIClient (protocol)

/// A general JSON 'send and recieve' asynchronic network thingy
protocol APIClient {
    var urlSession: URLSession { get }
}

extension APIClient {
    typealias JSONTaskCompletionHandler = (Decodable?, APIError?) -> Void

    // MARK: fetch (function)

    /// Fetch JSON
    /// - Parameters:
    ///   - request: The post request
    ///   - decode: The struct to use for decoding
    ///   - completion: Black magic

    func fetch<T: Decodable>(
        with request: URLRequest,
        decode: @escaping (Decodable) -> T?,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        let task = decodingTask(with: request, decodingType: T.self) { json, error in
            /// Change to main queue
            DispatchQueue.main.async {
                guard let json = json else {
                    if let error = error {
                        completion(Result.failure(error))
                    } else {
                        completion(Result.failure(.invalidData))
                    }
                    return
                }
                if let value = decode(json) {
                    completion(.success(value))
                } else {
                    completion(.failure(.jsonParsingFailure))
                }
            }
        }
        task.resume()
    }

    // MARK: decodingTask (function)

    /// Decode a response
    /// - Parameters:
    ///   - request: The post request
    ///   - decodingType: The struct to use for decoding
    ///   - completion: Black magic
    /// - Returns: Downloaded data

    func decodingTask<T: Decodable>(
        with request: URLRequest,
        decodingType: T.Type,
        completionHandler completion: @escaping JSONTaskCompletionHandler
    ) -> URLSessionDataTask {
        let task = urlSession.dataTask(with: request) { data, response, _ in
            // debugJsonResponse(data: data!)
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, .requestFailed)
                return
            }
            if httpResponse.statusCode == 200 {
                if let data = data {
                    do {
                        let genericModel = try JSONDecoder().decode(decodingType, from: data)
                        completion(genericModel, nil)
                    } catch {
                        completion(nil, .jsonConversionFailure)
                    }
                } else {
                    completion(nil, .invalidData)
                }
            } else {
                completion(nil, .responseUnsuccessful)
            }
        }
        return task
    }
}

// MARK: - APIError (error)

/// List of possible errors
enum APIError: Error {
    case requestFailed
    case jsonConversionFailure
    case invalidData
    case responseUnsuccessful
    case jsonParsingFailure
    var localizedDescription: String {
        switch self {
        case .requestFailed:
            return "Request Failed"
        case .invalidData:
            return "Invalid Data"
        case .responseUnsuccessful:
            return "Response Unsuccessful"
        case .jsonParsingFailure:
            return "JSON Parsing Failure"
        case .jsonConversionFailure:
            return "JSON Conversion Failure"
        }
    }
}
