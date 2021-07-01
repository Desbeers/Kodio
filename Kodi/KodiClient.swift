///
/// KodiClient.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - KodiClient (class)

/// The Class that has it all
class KodiClient: APIClient, ObservableObject {
    
    /// Use a shared instance
    static let shared = KodiClient()

    // MARK: hosts (variable)
    /// An array with all Kodo hosts
    @Published var hosts: [HostFields]
    /// The  selected Kodi host
    @Published var selectedHost: HostFields
    @Published var properties = KodiProperties()
    var hostTimer: Timer?
    var volumeTimer: Timer?
    
    var userInterface: UserInterface = .macOS

    // MARK: urlSession (variable)
    /// The URL session
    let urlSession: URLSession

    // MARK: webSocketTask (task)
    /// The WebSocket task
    var webSocketTask: URLSessionWebSocketTask?
    /// Bool to turn notifications on and off
    var notificate = true

    // MARK: artists (variable)
    var artists = ArtistLists()

    // MARK: albums (variable)
    var albums = AlbumLists()

    // MARK: songs (variable)
    var songs = SongLists()

    // MARK: genres (variable)
    var genres = GenreLists()

    // MARK: playlists (variable)
    @Published var playlists = PlaylistLists()
    var playlistTimer: Timer?
    /// Jump from the playlist into the library
    @Published var libraryJump = LibraryJump()

    // MARK: search (variable)
    @Published var searchQuery: String = ""
    @Published var searchID = UUID().uuidString

    // MARK: player (variable)
    @Published var player = PlayerLists()

    // MARK: library (variable)
    /// Library loading status
    @Published var library = LibraryState()
    var libraryUpToDate: Bool = true
    var libraryIsScanning: Bool = false

    // MARK: debugLog (variable)
    @Published var debugLog = [DebugLog]()

    // MARK: init (function)

    /// Class init
    /// - Parameter configuration: URLSessionConfiguration
    
    init(configuration: URLSessionConfiguration) {
        /// Network stuff
        configuration.timeoutIntervalForRequest = 300
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForResource = 120
        self.urlSession = URLSession(configuration: configuration)
        /// Host stuff
        self.hosts = getAllHosts()
        self.selectedHost = getSelectedHost()
    }
    /// Black magic
    convenience init() {
        self.init(configuration: .ephemeral)
        if hosts.isEmpty {
            library.online = false
        }
        connectHost()
        /// Keep checking Kodi
        hostTimer = Timer.scheduledTimer(
            withTimeInterval: 10, repeats: true, block: { [weak self] _ in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    self?.connectHost()
                }
            })
        
    }
}
