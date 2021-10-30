//
//  LibrarySmartLists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: - Smart lists
    
    /// Get a list of recently played and recently added songs
    /// - Returns: true when loaded of false if the is an error
    func getSmartItems() async -> Bool {
        let recent = AudioLibraryGetSongIDs(media: .recentlyPlayed)
        let most = AudioLibraryGetSongIDs(media: .mostPlayed)
        do {
            /// Recently played
            async let recent = KodiClient.shared.sendRequest(request: recent)
            recentlyPlayedSongs = songIDtoSongItem(songID: try await recent.songs)
            /// Most played
            async let most = KodiClient.shared.sendRequest(request: most)
            mostPlayedSongs = songIDtoSongItem(songID: try await most.songs)
            logger("Smart items loaded")
            /// If this item is selected; refresh the UI
            if media == .recentlyPlayed || media == .mostPlayed {
                filterAllMedia()
            }
            return true
        } catch {
            print("Loading smart items failed with error: \(error)")
            return false
        }
    }
    
    /// Change a list with song id's to a list with the actual songs
    /// - Parameter songID: an array with ``SongIdItem`` structs
    /// - Returns: an array with ``SongItem`` structs
    private func songIDtoSongItem(songID: [SongIdItem]) -> [SongItem] {
        var songList = [SongItem]()
        for song in songID {
            if let item = allSongs.first(where: { $0.songID == song.songID }) {
                songList.append(item)
            }
        }
        return songList
    }
    
    /// Select or deselect a smart list and filter the library
    /// - Parameter smartList: a ``SmartListItem`` struct
    func toggleSmartList(smartList: SmartListItem) {
        selectedSmartList = smartList
        switch smartList.media {
        case .playlist:
            let request = FilesGetDirectory(directory: smartList.file)
            Task {
                do {
                    let result = try await KodiClient.shared.sendRequest(request: request)
                    var songList = [SongItem]()
                    for song in result.files {
                        if let item = allSongs.first(where: { $0.songID == song.songID }) {
                            songList.append(item)
                        }
                    }
                    playlistSongs = songList
                    /// Reload lists
                    smartReload()
                } catch {
                    print(error)
                }
            }
        case .random:
            randomSongs = Array(allSongs
                                    .filter {!$0.title.contains("(Live)")}
                                    .filter {!$0.genre.contains("Musical")}
                                    .filter {!$0.genre.contains("Cabaret")}
                                    .shuffled().prefix(100))
            /// Reload lists
            smartReload()
        case .neverPlayed:
            neverPlayedSongs = Array(allSongs
                                        .filter {$0.playCount == 0}
                                        .shuffled().prefix(100))
            /// Reload lists
            smartReload()
        default:
            /// Reload lists
            smartReload()
        }
    }
    
    /// Get the smart lists
    func getSmartLists() {
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
                                  media: .queue
                                 ))
        allSmartLists = list
        /// Select the first item
        selectedSmartList = list.first!
    }
    
    /// The struct for a smart list item
    struct SmartListItem: LibraryItem {
        var id = UUID()
        var title: String = "Kodio"
        var subtitle = "Loading your library"
        var description: String = ""
        var icon: String = "k.circle"
        var media: MediaType = .albumArtists
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
        selectedGenre = nil
        selectedArtist = nil
        selectedAlbum = nil
        /// Set the filter
        setFilter(item: selectedSmartList)
        /// Reload all media
        filterAllMedia()
    }
}
