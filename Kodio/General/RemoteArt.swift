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
    /// Have all remote art available in the SwiftUI environment
    var remoteArt: RemoteArt {
        get { self[RemoteArtKey.self] }
        set { self[RemoteArtKey.self ] = newValue}
    }
}

/// An Actor holding all remote art in a cache
actor RemoteArt {
    
    /// The state of caching art
    private enum CacheEntry {
        /// The remote art is still loading
        case inProgress(Task<Image, Error>)
        /// The remote art is cached
        case ready(Image)
    }

    /// The cache with the art
    private var cache: [URL: CacheEntry] = [:]

    /// Get remote art from the Kodi host
    /// - Parameters:
    ///   - item: A ``LibraryItem``
    ///   - art: The kind of art to fetch; a thumbnail or fanart
    /// - Returns: An SwiftUI ``Image``
    func getArt(item: LibraryItem, art: String) async throws -> Image? {
        /// Convert image path to a full URL
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
            try await downloadArt(item: item, from: url)
        }
        /// Set the state of loading in the cache
        cache[url] = .inProgress(task)
        /// Download the art
        do {
            let art = try await task.value
            cache[url] = .ready(art)
            return art
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
    private func downloadArt(item: LibraryItem, from: URL) async throws -> Image {
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
