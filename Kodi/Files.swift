///
/// Files.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - Files.GetDirectory (API request)

struct FilesGetDirectory: KodiRequest {
    /// Arguments
    var directory: String
    /// Method
    var method = Method.filesGetDirectory
    /// The JSON creator
    var parameters: Data {
        var params = Params()
        params.directory = directory
        return buildParams(params: params)
    }
    /// The request struct
    struct Params: Encodable {
        var directory = ""
        let media = "music"
    }
    // typealias response = Response
    /// The response struct
    struct Response: Decodable {
        let files: [FileFields]
    }
}

// MARK: - FileFields (struct)

/// The fields for a file

struct FileFields: Decodable, Identifiable, Hashable {
    var id = UUID()
    var file: String
    var songID: Int
    let label: String
}

extension FileFields {
    enum CodingKeys: String, CodingKey {
        case file, label
        case songID = "id"
    }
}

extension FileFields {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        file = try container.decode(String.self, forKey: .file)
        songID = try container.decodeIfPresent(Int.self, forKey: .songID) ?? 0
        label = (try container.decode(String.self, forKey: .label)).removeExtension()
    }
}
