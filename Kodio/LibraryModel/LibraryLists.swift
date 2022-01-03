//
//  LibraryLists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Library lists
    
    /// A struct with all library list related items
    struct LibraryLists {
        /// A list containing all library list items
        var all = [LibraryListItem]()
        /// The selected library list in the UI
        var selected = LibraryListItem()
    }
    
    /// /// Select a library list and filter the library
    /// - Parameters:
    ///   - libraryList: A ``LibraryListItem`` struct
    ///   - reset: True if we want a fresh view, false if we just want to update it
    func selectLibraryList(libraryList: LibraryListItem, reset: Bool = true) async {
        /// Set the selection
        libraryList.set(reset: reset)
        /// Filter the songs
        var filteredSongs = [SongItem]()
        async let songList = filterSelection()
        songs.selection = await songList
        if reset {
            filteredSongs = songs.selection
            /// Update dynamic lists
            await AppState.shared.updateSidebar()
        } else {
            filteredSongs = await filterSongs()
        }
        /// Now the rest
        let albums = await filterAlbums(songList: songs.selection)
        let artists = await filterArtists(songList: songs.selection)
        let genres = await filterGenres(songList: songs.selection)
        /// Update the View
        await updateLibraryView(
            content:
                FilteredContent(
                    genres: genres,
                    artists: artists,
                    albums: albums,
                    songs: filteredSongs
                )
        )
    }
    
    /// Get the library list items
    func getLibraryLists() -> [LibraryListItem] {
        var list = [LibraryListItem]()
        list.append(LibraryListItem(title: "Album Artists",
                                    subtitle: "All songs from your album artists",
                                    empty: "Your library has no album artists",
                                    icon: "music.mic",
                                    media: .albumArtists))
        list.append(LibraryListItem(title: "Compilations",
                                    subtitle: "All songs from your compilation albums",
                                    empty: "Your library has no compilations",
                                    icon: "person.2",
                                    media: .compilations
                                   ))
        list.append(LibraryListItem(title: "Recently Added",
                                    subtitle: "What's new in you library",
                                    empty: "Your library has nothing recently added",
                                    icon: "star",
                                    media: .recentlyAdded
                                   ))
        list.append(LibraryListItem(title: "Most Played",
                                    subtitle: "The songs that you play the most",
                                    empty: "Your library has no most played songs",
                                    icon: "infinity",
                                    media: .mostPlayed
                                   ))
        list.append(LibraryListItem(title: "Recently Played",
                                    subtitle: "Your recently played songs",
                                    empty: "Your library has no recently played songs",
                                    icon: "gobackward",
                                    media: .recentlyPlayed
                                   ))
        list.append(LibraryListItem(title: "Favorites",
                                    subtitle: "Your favorite songs",
                                    empty: "Your library has no favorite songs",
                                    icon: "heart",
                                    media: .favorites
                                   ))
        list.append(LibraryListItem(title: "Playing Queue",
                                    subtitle: "This is in your current playing queue",
                                    empty: "The playing queue is empty",
                                    icon: "music.note.list",
                                    media: .queue,
                                    visible: !Player.shared.queueSongs.isEmpty
                                   ))
        list.append(LibraryListItem(title: "Search",
                                    subtitle: "Results for '\(search.query)'",
                                    empty: "Nothing found for '\(search.query)' in your library",
                                    icon: "magnifyingglass",
                                    media: .search,
                                    visible: !search.query.isEmpty
                                   ))
        /// Save the list and return it
        libraryLists.all = list
        return list
    }
    
    /// The struct for a library list item
    struct LibraryListItem: LibraryItem, Identifiable, Hashable {
        /// Make it indentifiable
        var id: String {
            return title
        }
        /// Ttitle of the item
        var title: String = "Kodio"
        /// Subtitle of the item
        var subtitle = "Loading your library"
        /// Description of the item
        var description: String = ""
        /// Empty item message
        /// - Note: Not needed, but required by protocol
        var empty: String = "Loading your library"
        /// The SF symbol for this media item
        var icon: String = "k.circle"
        /// Media type of this item
        var media: MediaType = .none
        /// Visibility of item
        var visible: Bool = true
        /// Used for Kodi playlist files
        var file: String = ""
        /// Thumbnail of this item
        /// - Note: Not needed, but required by protocol
        let thumbnail: String = ""
        /// Fanart of this item
        /// - Note: Not needed, but required by protocol
        let fanart: String = ""
        /// Details for the artist
        /// - Note: Not needed, but required by protocol
        let details: String = ""
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case title
        }
    }
}
