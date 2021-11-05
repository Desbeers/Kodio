//
//  LibrarySmartLists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Smart lists
    
    /// A struct will all smart list related items
    struct SmartLists {
        /// A list containng all smart lists
        var all = [SmartListItem]()
        /// The selected smart list in the UI
        var selected = SmartListItem()
    }
    
    /// Get a list of recently played and recently added songs from the Kodi host
    /// - Returns: True when loaded; else false
    func getSmartItems() async -> Bool {
        let recent = AudioLibraryGetSongIDs(media: .recentlyPlayed)
        let most = AudioLibraryGetSongIDs(media: .mostPlayed)
        do {
            /// Recently played
            async let recent = KodiClient.shared.sendRequest(request: recent)
            songs.recentlyPlayed = songIDtoSongItem(songID: try await recent.songs)
            /// Most played
            async let most = KodiClient.shared.sendRequest(request: most)
            songs.mostPlayed = songIDtoSongItem(songID: try await most.songs)
            logger("Smart items loaded")
            /// If this item is selected; refresh the UI
            if filter == .recentlyPlayed || filter == .mostPlayed {
                filterAllMedia()
            }
            return true
        } catch {
            print("Loading smart items failed with error: \(error)")
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
    
    /// Select or deselect a smart list and filter the library
    /// - Parameter smartList: A ``SmartListItem`` struct
    func toggleSmartList(smartList: SmartListItem) {
        smartLists.selected = smartList
        switch smartList.media {
        case .playlist:
            Task {
                let songList = await getPlaylistSongs(file: smartList.file)
                playlists.songs = songList
            }
        case .random:
            songs.random = Array(songs.all
                                    .filter {!$0.title.contains("(Live)")}
                                    .filter {!$0.genre.contains("Musical")}
                                    .filter {!$0.genre.contains("Cabaret")}
                                    .shuffled().prefix(100))
        case .neverPlayed:
            songs.neverPlayed = Array(songs.all
                                        .filter {$0.playCount == 0}
                                        .shuffled().prefix(100))
        default:
            break
        }
        /// Reload lists
        smartReload()
    }
    
    /// Get the smart list items
    func getSmartLists() -> [SmartListItem] {
        var list = [SmartListItem]()
        list.append(SmartListItem(title: "Album artists",
                                  subtitle: "All your album artists",
                                  icon: "music.mic",
                                  media: .albumArtists))
        list.append(SmartListItem(title: "Compilations",
                                  subtitle: "All your compilations",
                                  icon: "person.2",
                                  media: .compilations
                                 ))
        list.append(SmartListItem(title: "Recently added",
                                  subtitle: "What's new in you library",
                                  icon: "clock",
                                  media: .recentlyAdded
                                 ))
        list.append(SmartListItem(title: "Most played",
                                  subtitle: "The songs that you play the most",
                                  icon: "infinity",
                                  media: .mostPlayed
                                 ))
        list.append(SmartListItem(title: "Recently played",
                                  subtitle: "Your last played songs",
                                  icon: "gobackward",
                                  media: .recentlyPlayed
                                 ))
        list.append(SmartListItem(title: "Favorites",
                                  subtitle: "Your favorite songs",
                                  icon: "star",
                                  media: .favorites
                                 ))
        list.append(SmartListItem(title: "Playing queue",
                                  subtitle: "This is in your current playlist",
                                  icon: "music.note.list",
                                  media: .queue,
                                  visible: !Queue.shared.songs.isEmpty
                                 ))
        list.append(SmartListItem(title: "Search",
                                  subtitle: "Results for '\(query)'",
                                  icon: "magnifyingglass",
                                  media: .search,
                                  visible: !query.isEmpty
                                 ))
        /// Save the list
        smartLists.all = list
        /// Select default if selected item is not visible
        if let selection = list.first(where: { $0.media == smartLists.selected.media }), !selection.visible {
            logger("Select first item in the sidebar")
            toggleSmartList(smartList: list.first!)
        }
        return list
    }
    
    /// The struct for a smart list item
    struct SmartListItem: LibraryItem {
        var id: String {
            return title
        }
        var title: String = "Kodio"
        var subtitle = "Loading your library"
        var description: String = ""
        var icon: String = "k.circle"
        var media: MediaType = .albumArtists
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

    /// Reload the library when changing a smart filter
    func smartReload() {
        /// Reset selection
        genres.selected = nil
        artists.selected = nil
        albums.selected = nil
        /// Set the filter
        setLibraryFilter(item: smartLists.selected)
        /// Reload all media
        filterAllMedia()
    }
}
