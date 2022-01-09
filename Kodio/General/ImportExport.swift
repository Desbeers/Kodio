//
//  ImportExport.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI
import UniformTypeIdentifiers

/// The Kodio Import/Export document
struct KodioDocument: FileDocument {
    /// The types we can read
    static var readableContentTypes: [UTType] { [.plainText] }
    /// The content
    var content: String
    /// Init the content
    init(content: String) {
        self.content = content
    }
    /// Init the configuration
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        content = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
    }
    
}
