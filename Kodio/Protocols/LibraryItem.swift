//
//  LibraryItem.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

/// A protocol to define an item in the library: artist, album, song, playlist etc.
protocol LibraryItem: Codable, Identifiable, Hashable {
    /// The kind of ``Library/MediaType``
    var media: Library.MediaType { get }
    /// The title of the item
    var title: String { get }
    /// The subtitle of the item
    var subtitle: String { get }
    /// The decription of the item
    var description: String { get }
    /// The SF symbol icon for this type
    var icon: String { get }
    /// The thumbnail for the item
    var thumbnail: String { get }
    /// The fanart for the item
    var fanart: String { get }
}
