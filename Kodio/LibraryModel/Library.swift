//
//  Library.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation
import Combine

/// The Library model
///
/// This class takes care of:
/// - Loading the music libray
/// - Filter the library based on UI selection
class Library: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this Library class
    static let shared = Library()
    /// Combine subscription container
    var anyCancellable = Set<AnyCancellable>()
    /// The shared client class
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
    /// The search query
    @Published var query = ""
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
    /// An array with all radio stations
    var radioStations: [RadioItem] = []
    
    // MARK: Init the Library class
    
    /// Private init to make sure we have only one instance
    private init() {
        /// Search observer
        search.observer.objectWillChange.sink { [self] in
            DispatchQueue.main.async {
                if search.observer.query != query {
                    query = search.observer.query
                    searchLibrary()
                }
            }
        }.store(in: &anyCancellable)
    }
}

extension Library {
 
    // MARK: Sorting of media
    
    /// The sort fields for JSON requests
    struct SortFields: Encodable {
        /// The method
        var method: String = ""
        /// The order
        var order: String = ""
    }

    /// The sort methods for JSON requests
    enum SortMethod: String {
        /// Order descending
        case descending = "descending"
        /// Order ascending
        case ascending = "ascending"
        ///  Order by last played
        case lastPlayed = "lastplayed"
        ///  Order by play count
        case playCount = "playcount"
        ///  Order by year
        case year = "year"
        ///  Order by track
        case track = "track"
        ///  Order by artist
        case artist = "artist"
        ///  Order by title
        case title = "title"
        /// Nicer that using rawValue
        func string() -> String {
            return self.rawValue
        }
    }
}
