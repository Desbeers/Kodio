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
            /// The parameters
            var params = Params()
            params.directory = directory
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// The direcory we ask for
            var directory = ""
            /// Media type we ask for
            let media = "music"
        }
        /// The response struct
        struct Response: Decodable {
            /// The list with files
            let files: [FileItem]
        }
    }
    
    /// The struct for a file item
    struct FileItem: LibraryItem {
        /// Make it identifiable
        var id = UUID().uuidString
        /// Name of the file
        var file: String
        /// Song ID
        var songID: Int
        /// Label of the file
        let label: String
        /// The media type
        let media: MediaType = .playlist
        /// The SF symbol for this media item
        var icon: String {
            var sfSymbol = "music.note.list"
            if file.hasSuffix(".xsp") {
                sfSymbol = "list.star"
            }
            return sfSymbol
        }
        /// Title of the file
        var title: String {
            return label
        }
        /// Subtitle of the file
        var subtitle: String {
            return description
        }
        /// Description of the file
        var description: String {
            /// Description
            var text = "A Kodi playlist"
            if file.hasSuffix(".xsp") {
                text = "A Kodi smart playlist"
            }
            return text
        }
        /// Empty item message
        /// - Note: Not needed, but required by protocol
        let empty: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case file, label
            /// lowerCamelCase
            case songID = "id"
        }
        /// Thumbnail of the file
        /// - Note: Not needed, but required by protocol
        let thumbnail: String = ""
        /// Fanart for the file
        /// - Note: Not needed, but required by protocol
        let fanart: String = ""
        /// Details for the file
        /// - Note: Not needed, but required by protocol
        let details: String = ""
        /// Custom init
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            file = try container.decode(String.self, forKey: .file)
            songID = try container.decodeIfPresent(Int.self, forKey: .songID) ?? 0
            label = (try container.decode(String.self, forKey: .label)).removeExtension()
        }
    }
}
