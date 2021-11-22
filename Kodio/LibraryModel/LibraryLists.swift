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
        /// The selected libray list in the UI
        var selected = LibraryListItem()
    }

    /// Select a library list and filter the library
    /// - Parameter libraryList: A ``LibraryListItem`` struct
    func selectLibraryList(libraryList: LibraryListItem) {
        libraryLists.selected = libraryList
        Task { @MainActor in
            AppState.shared.updateSidebar()
        }
        switch libraryList.media {
        case .playlist:
            Task {
                async let songList = getPlaylistSongs(file: libraryList.file)
                playlists.songs = await songList
                libraryReload()
            }
        case .random:
            songs.random = Array(songs.all
                                    .filter {!$0.title.contains("(Live)")}
                                    .filter {!$0.genre.contains("Musical")}
                                    .filter {!$0.genre.contains("Cabaret")}
                                    .shuffled().prefix(100))
            libraryReload()
        case .neverPlayed:
            songs.neverPlayed = Array(songs.all
                                        .filter {$0.playCount == 0}
                                        .shuffled().prefix(100))
            libraryReload()
        default:
            libraryReload()
        }
    }
    
    /// Get the library list items
    func getLibraryLists() -> [LibraryListItem] {
        var list = [LibraryListItem]()
        list.append(LibraryListItem(title: "Album artists",
                                    subtitle: "All your album artists",
                                    empty: "Your library has no album artists",
                                    icon: "music.mic",
                                    media: .albumArtists))
        list.append(LibraryListItem(title: "Compilations",
                                    subtitle: "All your compilations",
                                    empty: "Your library has no compilations",
                                    icon: "person.2",
                                    media: .compilations
                                   ))
        list.append(LibraryListItem(title: "Recently added",
                                    subtitle: "What's new in you library",
                                    empty: "Your library has nothing recently added",
                                    icon: "star",
                                    media: .recentlyAdded
                                   ))
        list.append(LibraryListItem(title: "Most played",
                                    subtitle: "The songs that you play the most",
                                    empty: "Your library has no most played songs",
                                    icon: "infinity",
                                    media: .mostPlayed
                                   ))
        list.append(LibraryListItem(title: "Recently played",
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
        list.append(LibraryListItem(title: "Playing queue",
                                    subtitle: "This is in your current playlist",
                                    empty: "The queue is empty",
                                    icon: "music.note.list",
                                    media: .queue,
                                    visible: !Player.shared.queueItems.isEmpty
                                   ))
        list.append(LibraryListItem(title: "Search",
                                    subtitle: "Results for '\(query)'",
                                    empty: "Nothing found for '\(query)' in your library",
                                    icon: "magnifyingglass",
                                    media: .search,
                                    visible: !query.isEmpty
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
        /// Is this item selected?
        var selected: Bool {
            return Library.shared.libraryLists.selected.id == self.id ? true : false
        }
        /// Coding keys
        enum CodingKeys: String, CodingKey {
            /// The keys
            case title
        }
    }
    
    /// Reload the library when changing a library filter
    private func libraryReload() {
        /// Reset selection
        genres.selected = nil
        artists.selected = nil
        albums.selected = nil
        /// Set the selection
        setLibrarySelection(item: libraryLists.selected)
        /// Reload all media
        filterAllMedia()
    }
}
