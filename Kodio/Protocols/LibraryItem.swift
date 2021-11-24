//
//  LibraryItem.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

/// A protocol to define an item in the library: artist, album, song, playlist etc.
protocol LibraryItem: Codable {
    /// The ID of the item
    var id: String { get }
    /// The kind of ``Library/MediaType``
    var media: Library.MediaType { get }
    /// The title of the item
    var title: String { get }
    /// The subtitle of the item
    var subtitle: String { get }
    /// The details of the item
    var details: String { get }
    /// The decription of the item
    var description: String { get }
    /// Message to show when the library item is empty
    var empty: String { get }
    /// The SF symbol for this media item icon for this type
    var icon: String { get }
    /// The thumbnail for the item
    var thumbnail: String { get }
    /// The fanart for the item
    var fanart: String { get }
}

extension LibraryItem {

    /// Set the library item as new selection
    ///
    /// - Genres, artist and albums will be *toggled* and selections reset if needed
    /// - Library lists will always be selected
    func set() {
        let library: Library = .shared
        switch self.media {
        case .genre:
            /// Reset artists and albums
            library.artists.selected = nil
            library.albums.selected = nil
            library.genres.selected = selected() ? nil : self as? Library.GenreItem
        case .artist:
            /// Reset albums
            library.albums.selected = nil
            library.artists.selected = selected() ? nil : self as? Library.ArtistItem
        case .album:
            library.albums.selected = selected() ? nil : self as? Library.AlbumItem
        default:
            /// A `LibraryListItem`
            /// Reset genres, artists and albums
            library.genres.selected = nil
            library.artists.selected = nil
            library.albums.selected = nil
            library.libraryLists.selected = self as? Library.LibraryListItem ?? library.libraryLists.all.first!
        }
        library.selection = getSelection()
        logger("Selected \(library.selection.title)")
    }

    /// Check if the current `LibraryItem` is selected in the UI or not
    /// - Returns: True or false
    func selected() -> Bool {
        /// Get the shared Library class
        let library: Library = .shared
        /// Set the selection based on `MediaType`
        switch self.media {
        case .artist:
            return self as? Library.ArtistItem == library.artists.selected ? true : false
        case .album:
            return self as? Library.AlbumItem == library.albums.selected ? true : false
        case .genre:
            return self as? Library.GenreItem == library.genres.selected ? true : false
        default:
            /// A library list item
            return Library.shared.libraryLists.selected.id == self.id ? true : false
        }
    }

    /// Get the most fitting `LibraryItem` as selection
    /// - Returns: A `LibraryItem`
    private func getSelection() -> LibraryItem {
        /// Get the shared Library class
        let library: Library = .shared
        /// Find the the most fillting selection
        if let album = library.albums.selected {
            return album
        } else if let artist = library.artists.selected {
            return artist
        } else if let genre = library.genres.selected {
            return genre
        }
        /// Return default
        return library.libraryLists.selected
    }
}
