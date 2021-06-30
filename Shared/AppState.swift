//
//  AppState.swift
//  Kodio
//
//  Created by Nick Berendsen on 01/06/2021.
//

import SwiftUI

// MARK: - AppState (class)

/// The state of the application
class AppState: ObservableObject {
    /// Use a shared instance of the AppState class
    static let shared = AppState()
    /// Tab selector
    @Published var tabs = TabViews()
    /// Show or hide a SwiftUI Sheet
    @Published var showSheet: Bool = false
    /// The Struct for an SwiftUI Alert
    @Published var alertItem: AlertItem?
    /// Define what sheet to show
    @Published var activeSheet: Sheets = .editHosts
    /// Selected items
    @Published var selectedArtist: ArtistFields? {
        willSet {
            if newValue != nil {
                print("Artist selected")
                filter.albums = .artist
                filter.songs = .artist
                tabs.tabDetails = .songs
            }
        }
    }
    @Published var selectedAlbum: AlbumFields? {
        willSet {
            if newValue != nil {
                print("Album selected")
                filter.songs = .album
                tabs.tabDetails = .songs
            }
        }
    }
    @Published var selectedGenre: GenreFields? {
        willSet {
            if newValue != nil {
                print("Genre selected")
                filter.albums = .genre
                filter.songs = .genre
                tabs.tabDetails = .songs
            }
        }
    }
    @Published var selectedSmartList: SmartMenuFields? {
        willSet {
            if newValue != nil {
                print("Smart list selected")
                filter.albums = newValue!.filter
                filter.songs = newValue!.filter
                tabs.tabDetails = .songs
            }
        }
    }
    @Published var selectedPlaylist: String?
    
    var filter = MediaFilter()
}

extension AppState {
    
    // MARK: Tab View selector
    
    /// The selected tabs
    struct TabViews {
        var tabSidebar: TabOptions = .artists
        var tabDetails: TabOptions = .songs
    }
    /// The available tabs
    enum TabOptions {
        case artists, genres, songs, playqueue, playlists
    }
}

extension AppState {
    
    // MARK: Sheets
    
    /// The different kind of sheets
    enum Sheets {
        case editHosts
        case viewArtistInfo
        case viewAlbumInfo
    }
}

extension AppState {
    
    // MARK: AlertItem (struct)
    
    /// Contruct a SwiftUI Alert
    struct AlertItem: Identifiable {
        var id = UUID()
        var title = Text("")
        var message: Text?
        var button: Alert.Button?
    }
}
