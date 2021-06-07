///
/// Extensions.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI
import CryptoKit

// MARK: - Typealias: get the correct Image function for macOS and iOS

#if os(macOS)
typealias SWIFTImage = NSImage
#endif
#if os(iOS)
typealias SWIFTImage = UIImage
#endif

// MARK: - Extension: if (if Bool -> modifier)

extension View {
  @ViewBuilder
  func `if`<Transform: View>(
    _ condition: Bool,
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

// MARK: - Extension: hidden (isHidden: Bool)

extension View {
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = true) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

// MARK: - Extension: String

extension String {
    
    // MARK: stringToDate (function)
    
    /// Convert Kodi date strings to Date()
    /// - Returns: Date()
    
    func stringToDate() -> Date {
        /// Create Date Formatter
        let dateFormatter = DateFormatter()
        /// Set format of Date Formatter
        dateFormatter.dateFormat = "y-M-d HH:mm:ss"
        /// A date long, long time ago (used in case of empty string')
        let lastPlayed = dateFormatter.date(from: "1900-01-01 00:00:01")!
        return dateFormatter.date(from: self) ?? lastPlayed
    }

    // MARK: kodiImageUrl (function)
    
    /// Convert image path to full URL
    /// - ToDo: Change this function to new selector
    /// - Returns: A string representing the full image URL
    
    func kodiImageUrl() -> String {
        let host = getSelectedHost()
        /// Encoding
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~") /// as per RFC 3986
        /// Image URL
        let kodiImageAddress = "http://\(host.username):\(host.password)@\(host.ip):\(host.port)/image/"
        return kodiImageAddress + self.addingPercentEncoding(withAllowedCharacters: allowed)!
    }

    // MARK: removeExtension
    
    /// Remove extension from label
    /// - Returns: String without extension
    
    func removeExtension() -> String {
        return self.components(separatedBy: ".").first ?? "Error in label"
    }

    // MARK: md5 (function)
    
    /// String to MD5; it's used for the image cache.
    /// - Returns: An md5 string
    
    func md5() -> String {
        return Insecure.MD5.hash(data: self.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
    }
}

// MARK: - Extension: ContentView

extension ViewContent {
    
    /// You can only have one sheet in a view.
    /// This extension makes it possible to have different views.
    @ViewBuilder func sheetContent() -> some View {
        switch appState.activeSheet {
        case .editHosts:
            ViewKodiEditHosts()
        case .viewArtistInfo:
            ViewDescription(artist: kodi.artists.selected)
        case .viewAlbumInfo:
            ViewDescription(album: kodi.albums.selected)
        }
    }
    /// A general Alert constructor
    func alertContent( _ alertItem: AppState.AlertItem) -> Alert {
        guard let primaryButton = alertItem.button else {
            return Alert(title: alertItem.title,
                         message: alertItem.message,
                         dismissButton: .cancel()
            )
        }
        return Alert(
            title: alertItem.title,
            message: alertItem.message,
            primaryButton: primaryButton,
            secondaryButton: .cancel()
        )
    }
}
