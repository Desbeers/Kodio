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
    
    /// Get a list of recently played and recently added songs from the Kodi host
    /// - Returns: True when loaded; else false
    func getLibraryListItems() async -> Bool {
        let recent = AudioLibraryGetSongIDs(media: .recentlyPlayed)
        let most = AudioLibraryGetSongIDs(media: .mostPlayed)
        do {
            /// Recently played
            async let recent = KodiClient.shared.sendRequest(request: recent)
            songs.recentlyPlayed = songIDtoSongItem(songID: try await recent.songs)
            /// Most played
            async let most = KodiClient.shared.sendRequest(request: most)
            songs.mostPlayed = songIDtoSongItem(songID: try await most.songs)
            logger("Library lists loaded")
            /// If this item is selected; refresh the UI
            if selection.media == Library.MediaType.recentlyPlayed || selection.media == Library.MediaType.mostPlayed {
                filterAllMedia()
            }
            return true
        } catch {
            print("Loading library items failed with error: \(error)")
            return false
        }
    }
    
    /// Change a list with song id's to a list with the actual songs
    /// - Parameter songID: An array with ``SongIdItem`` structs
    /// - Returns: An array with ``SongItem`` structs
    private func songIDtoSongItem(songID: [SongIdItem]) -> [SongItem] {
        var songList = [SongItem]()
        for song in songID {
            if let item = songs.all.first(where: { $0.songID == song.songID }) {
                songList.append(item)
            }
        }
        return songList
    }
    
    /// Select a library list and filter the library
    /// - Parameter libraryList: A ``LibraryListItem`` struct
    func selectLibraryList(libraryList: LibraryListItem) {
        libraryLists.selected = libraryList
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
                                  icon: "music.mic",
                                  media: .albumArtists))
        list.append(LibraryListItem(title: "Compilations",
                                  subtitle: "All your compilations",
                                  icon: "person.2",
                                  media: .compilations
                                 ))
        list.append(LibraryListItem(title: "Recently added",
                                  subtitle: "What's new in you library",
                                  icon: "clock",
                                  media: .recentlyAdded
                                 ))
        list.append(LibraryListItem(title: "Most played",
                                  subtitle: "The songs that you play the most",
                                  icon: "infinity",
                                  media: .mostPlayed
                                 ))
        list.append(LibraryListItem(title: "Recently played",
                                  subtitle: "Your last played songs",
                                  icon: "gobackward",
                                  media: .recentlyPlayed
                                 ))
        list.append(LibraryListItem(title: "Favorites",
                                  subtitle: "Your favorite songs",
                                  icon: "star",
                                  media: .favorites
                                 ))
        list.append(LibraryListItem(title: "Playing queue",
                                  subtitle: "This is in your current playlist",
                                  icon: "music.note.list",
                                  media: .queue,
                                  visible: !Queue.shared.songs.isEmpty
                                 ))
        list.append(LibraryListItem(title: "Search",
                                  subtitle: "Results for '\(query)'",
                                  icon: "magnifyingglass",
                                  media: .search,
                                  visible: !query.isEmpty
                                 ))
        /// Save the list
        libraryLists.all = list
        /// Select default if selected item is not visible
        if let selection = list.first(where: { $0.media == libraryLists.selected.media }), !selection.visible {
            logger("Select first item in the sidebar")
            selectLibraryList(libraryList: list.first!)
        }
        return list
    }
    
    /// The struct for a library list item
    struct LibraryListItem: LibraryItem, Identifiable, Hashable {
        var id: String {
            return title
        }
        var title: String = "Kodio"
        var subtitle = "Loading your library"
        var description: String = ""
        var icon: String = "k.circle"
        var media: MediaType = .none
        /// Visibility of item
        var visible: Bool = true
        /// Used for Kodi playlist files
        var file: String = ""
        /// Not needed, but required by protocol
        let thumbnail: String = ""
        let fanart: String = ""
        enum CodingKeys: String, CodingKey {
            case title
        }
    }

    /// Reload the library when changing a library filter
    func libraryReload() {
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
