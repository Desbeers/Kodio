///
/// Base.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - General stuff (KodiClient extension)

extension KodiClient {
    
    // MARK: getLibrary (function)
    
    /// get all music items from the library
    /// - Parameters:
    ///     - reload: Bool; force a reload or else it will try to load it from the  cache
    /// - Returns: It will update the KodiClient variables
    func getLibrary(reload: Bool = false) {
        /// Opening state
        artists.selected = nil
        albums.selected = nil
        filter.albums = .compilations
        filter.songs = .compilations
        /// get media items
        getArtists(reload: reload)
        getAlbums(reload: reload)
        getSongs(reload: reload)
        getGenres(reload: reload)
        
    }
    
    // MARK: getLibraryDetails (function)
    
    /// Called by getSongs() when the whole library is loaded
    /// and when waking-up from sleep
    /// - Returns: It will update the KodiClient variables
    func getLibraryDetails() {
        log(#function, "Library loaded; getting details")
        getSmartLists()
        getPlaylistQueue()
        getPlaylistFiles()
        getPlayerProperties()
    }
    
    // MARK: getSmartMenu (function)
    
    /// Get the list of smart menu items
    /// - Returns: Struct of menu items

    func getSmartMenu() -> [SmartMenuFields] {
        var list = [SmartMenuFields]()
        list.append(SmartMenuFields(label: "Various artists", icon: "person.2", filter: .compilations))
        list.append(SmartMenuFields(label: "Recently added", icon: "clock", filter: .recentlyAdded))
        list.append(SmartMenuFields(label: "Most played", icon: "infinity", filter: .mostPlayed))
        list.append(SmartMenuFields(label: "Recently played", icon: "gobackward.10", filter: .recentlyPlayed))
        return list
    }
    
    // MARK: getSmartLists (function)
    
    /// get the dynamic lists from the library like recently played, last played etc.
    /// - Returns: Smart lists
    func getSmartLists() {
        getAlbumsSmartLists()
        getSongsSmartLists()
    }
    
    // MARK: applicationQuit (function)
    
    func applicationQuit(confirm: Bool = false) {
        if confirm {
            let request = SystemAction(api: .applicationQuit)
            sendMessage(request: request)
        } else {
            let alertItem = AppState.AlertItem(title: Text("Quit"),
                                      message: Text("Are you sure you want to quit Kodi?"),
                                      button: .default(Text("Quit"),
                                                       action: { self.applicationQuit(confirm: true) })
            )
            AppState.shared.alertItem = alertItem
        }
    }
}

// MARK: - Filter media stuff

/// The active filter for the artistlist, albumlist and songlists
struct MediaFilter {
    var artists: FilterType = .none
    var albums: FilterType = .none
    var songs: FilterType = .none
}
/// The type of filter that can be applied to either an
/// artistlist, albumlist or songlist.
enum FilterType: String {
    case none
    case artist
    case album
    case genre
    case playlist
    case compilations = "Random songs"
    case mostPlayed = "Most played songs"
    case recentlyAdded = "Recently added songs"
    case recentlyPlayed = "Recently played songs"
    case search = "Search library..."
}

// MARK: - Library loading status (struct)

/// The loading state of the library
struct LibraryState {
    /// Check if all items are loaded
    var all: Bool {
        if artists, albums, albumsRecent, albumsMost, songs, songsRecent, songsMost, genres, loaded {
            return true
        }
        return false
    }
    /// A Bool for being online or not
    var online: Bool = true
    /// True when the loading rewuest is done; loadig might be still in
    /// progress until 'all', as defined above is *true*.
    var loaded: Bool = false
    var artists: Bool = false
    var albums: Bool = false
    var albumsRecent: Bool = false
    var albumsMost: Bool = false
    var songs: Bool = false
    var songsRecent: Bool = false
    var songsMost: Bool = false
    var genres: Bool = false
    /// Bool if we have switched to a new library
    var switchHost: Bool = true
    /// Function to reset all vars to initial value
    mutating func reset() {
        self = LibraryState()
    }
}

// MARK: - SystemAction (API request)

/// Send an action to Kodi; not caring about the response
///
/// Usage:
///
///     let request = SystemAction(api: .applicationQuit)
///     sendMessage(request: request)

struct SystemAction: KodiRequest {
    /// Arguments
    var api: KodiAPI
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        return buildParams(method: method, params: Params())
    }
    /// The request struct
    struct Params: Encodable {
    }
    /// The response struct
    struct Response: Decodable {
        /// I don't care
    }
}

// MARK: - SmartMenuFields (struct)

/// Menu items for filtered content
struct SmartMenuFields: Identifiable, Hashable {
    var id = UUID()
    let label: String
    let icon: String
    let filter: FilterType
}

// MARK: - SmartMenuFields (struct)

/// Menu items for filtered content
enum UserInterface {
    case macOS, iPad, iPhone
}
