//
//  Image.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

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
