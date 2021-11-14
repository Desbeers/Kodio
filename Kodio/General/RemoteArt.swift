//
//  RemoteArt.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

#if os(macOS)
/// Alias NSIMage to make life easier in a multi platform application
typealias SWIFTImage = NSImage
#endif
#if os(iOS)
/// Alias UIIMage to make life easier in a multi platform application
typealias SWIFTImage = UIImage
#endif

/// The key for our ``RemoteImages`` for the SwiftUI environment
struct RemoteImagesKey: EnvironmentKey {
    static let defaultValue = RemoteImages()
}

extension EnvironmentValues {
    /// Keep an eye on the remote images in the environment
    var remoteImages: RemoteImages {
        get { self[RemoteImagesKey.self] }
        set { self[RemoteImagesKey.self ] = newValue}
    }
}

/// The Actor holding all remote images in a cache
actor RemoteImages {
    
    /// The state of caching an image
    private enum CacheEntry {
        /// The remote image is still loading
        case inProgress(Task<Image, Error>)
        /// The remote image is cached
        case ready(Image)
    }

    /// The cache of images
    private var cache: [URL: CacheEntry] = [:]

    /// Fetch a remote image
    /// - Parameters:
    ///   - item: A ``LibraryItem``
    ///   - art: The kind of art to show; a thumbnail or fanart
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
    
    /// Download a remote image
    /// - Parameters:
    ///   - item: A ``LibraryItem``
    ///   - from: the ``URL`` of the image
    /// - Returns: An ``Image``
    private func downloadImage(item: LibraryItem, from: URL) async throws -> Image {
        let (data, _) = try await URLSession.shared.data(from: from)
        
        if let image = SWIFTImage(data: data) {
#if os(macOS)
            return Image(nsImage: image)
#endif
#if os(iOS)
            return Image(uiImage: image)
#endif
        }
        return Image(systemName: item.icon)
    }
}

/// - Note: Not used yet

#if os(macOS)
extension NSImage {
    /// Return a thumbnail from an image
    /// - Parameter size: The maximum size for the thumbnail
    /// - Returns: A resized NSImage
    func getThumbnail(size: CGFloat) -> NSImage? {
        guard let imageData = self.tiffRepresentation else {
            return nil
        }
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: size * 2] as CFDictionary
        
        guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
            return nil
        }
        guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
            return nil
        }
        return NSImage(cgImage: imageReference, size: .zero)
    }
}
#endif

#if os(iOS)
extension UIImage {
    /// Return a thumbnail from an image
    /// - Parameter size: The maximum size for the thumbnail
    /// - Returns: A resized UIImage
    func getThumbnail(size: CGFloat) -> UIImage? {
    guard let imageData = self.pngData() else {
        return nil
    }
    let options = [
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: size * 2] as CFDictionary
    guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else {
        return nil
    }
    guard let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else {
        return nil
    }
    return UIImage(cgImage: imageReference)

  }
}
#endif
