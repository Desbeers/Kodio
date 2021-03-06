//
//  Library.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation
import Combine

/// The Library class
///
/// This class takes care of:
/// - Loading the music libray
/// - Filter the library based on UI selection
/// - Pass filtered content to the UI
/// - Do actions on ``LibraryItem``s
final class Library: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this Library class
    static let shared = Library()
    /// The shared KodiClient class
    let kodiClient = KodiClient.shared
    /// The current library selection
    var selection: LibraryItem = LibraryListItem()
    /// The status of the library
    var status = Status() {
        didSet {
            checkStatus()
        }
    }
    /// An array containing all search related items
    var search = Search()
    /// The library filtered by selection of library list, genre, artist and album
    @Published var filteredContent = FilteredContent()
    /// An array containing all artist related items
    var artists = Artists()
    /// An array containing all album related items
    var albums = Albums()
    /// An array containing all song related items
    var songs = Songs()
    /// An array containing all genre related items
    var genres = Genres()
    /// An array containing all library list related items
    var libraryLists = LibraryLists()
    /// An array containing all playlist related items
    var playlists = Playlists()
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {}
}
