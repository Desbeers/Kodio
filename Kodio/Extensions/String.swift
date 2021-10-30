//
//  String.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

// MARK: - Extension: String

extension String {

    // MARK: kodiImageUrl (function)
    
    /// Convert image path to a full URL
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
    
    // MARK: removeExtension
    
    /// Remove extension from label
    /// - Returns: String without extension
    func removeExtension() -> String {
        return self.components(separatedBy: ".").first ?? "Error in label"
    }
}
