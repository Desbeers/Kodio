//
//  RemoteArt.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The key for our ``RemoteArt`` for the SwiftUI environment
struct RemoteArtKey: EnvironmentKey {
    static let defaultValue = RemoteArt()
}

extension EnvironmentValues {
    /// Keep an eye on the remote art in the environment
    var remoteArt: RemoteArt {
        get { self[RemoteArtKey.self] }
        set { self[RemoteArtKey.self ] = newValue}
    }
}

/// The Actor holding all remote art in a cache
actor RemoteArt {
    
    /// The state of caching art
    private enum CacheEntry {
        /// The remote art is still loading
        case inProgress(Task<Image, Error>)
        /// The remote art is cached
        case ready(Image)
    }

    /// The cache of art
    private var cache: [URL: CacheEntry] = [:]

    /// Fetch remote art
    /// - Parameters:
    ///   - item: A ``LibraryItem``
    ///   - art: The kind of art to fetch; a thumbnail or fanart
    /// - Returns: An SwiftUI ``Image``
    func image(item: LibraryItem, art: String) async throws -> Image? {
        let url = URL(string: art.kodiImageUrl())!
        if let cached = cache[url] {
            switch cached {
            case .ready(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        let task = Task {
            try await downloadImage(item: item, from: url)
        }

        cache[url] = .inProgress(task)

        do {
            let image = try await task.value
            cache[url] = .ready(image)
            return image
        } catch {
            cache[url] = nil
            throw error
        }
    }
    
    /// Download remote art
    /// - Parameters:
    ///   - item: A ``LibraryItem``
    ///   - from: the ``URL`` of the art
    /// - Returns: An ``Image``
    private func downloadImage(item: LibraryItem, from: URL) async throws -> Image {
        let (data, _) = try await URLSession.shared.data(from: from)

#if os(macOS)
        if let image = NSImage(data: data) {
            return Image(nsImage: image)
        }
#endif
#if os(iOS)
        if let image = UIImage(data: data) {
            return Image(uiImage: image)
        }
#endif
        return Image(systemName: item.icon)
    }
}
