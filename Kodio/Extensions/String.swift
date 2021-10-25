//
//  String.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation
import CryptoKit

// MARK: - Extension: String

extension String {
    
    func toMarkdown() -> AttributedString {
      do {
        return try AttributedString(markdown: self)
      } catch {
        print("Error parsing Markdown for string \(self): \(error)")
        return AttributedString(self)
      }
    }
    
    // MARK: kodiImageUrl (function)
    
    /// Convert image path to full URL
    /// - ToDo: Change this function to new selector
    /// - Returns: A string representing the full image URL
    func kodiImageUrl() -> String {
        let host = KodiClient.shared.selectedHost
        /// Encoding
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~") /// as per RFC 3986
        /// Image URL
        let kodiImageAddress = "http://\(host.username):\(host.password)@\(host.ip):\(host.port)/image/"
        return kodiImageAddress + self.addingPercentEncoding(withAllowedCharacters: allowed)!
    }
    
    // MARK: md5 (function)
    
    /// String to MD5; it's used for the image cache.
    /// - Returns: An md5 string
    func md5() -> String {
        return Insecure.MD5.hash(data: self.data(using: .utf8)!).map { String(format: "%02hhx", $0) }.joined()
    }
    
    // MARK: removeExtension
    
    /// Remove extension from label
    /// - Returns: String without extension
    
    func removeExtension() -> String {
        return self.components(separatedBy: ".").first ?? "Error in label"
    }
}
