//
//  LibraryFiles.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Files
    
    /// Get the directories and files in the given directory (Kodi API)
    struct FilesGetDirectory: KodiAPI {
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
        /// The response struct
        struct Response: Decodable {
            let files: [FileItem]
        }
    }
    
    /// The struct for a file item
    struct FileItem: LibraryItem {
        var id = UUID().uuidString
        var file: String
        var songID: Int
        let label: String
        /// The media type
        let media: MediaType = .playlist
        var icon: String {
            var sfSymbol = "music.note.list"
            if file.hasSuffix(".xsp") {
                sfSymbol = "list.star"
            }
            return sfSymbol
        }
        var title: String {
            return label
        }
        var subtitle: String {
            return description
        }
        var description: String {
            var text = "A Kodi playlist"
            if file.hasSuffix(".xsp") {
                text = "A Kodi smart playlist"
            }
            return text
        }
        enum CodingKeys: String, CodingKey {
            case file, label
            case songID = "id"
        }
        /// Not needed, but required by protocol
        let thumbnail: String = ""
        let fanart: String = ""
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            file = try container.decode(String.self, forKey: .file)
            songID = try container.decodeIfPresent(Int.self, forKey: .songID) ?? 0
            label = (try container.decode(String.self, forKey: .label)).removeExtension()
        }
    }
}
