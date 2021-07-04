///
/// SmartLists.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import Foundation

class SmartLists: ObservableObject {
    /// Use a shared instance
    static let shared = SmartLists()
    let list = KodiClient.shared.getSmartMenu()
    @Published var selectedSmartList: SmartMenuFields? {
        didSet {
            if selectedSmartList != nil {
                print("Smart list selected")
                AppState.shared.tabs.tabDetails = .songs
                /// Deselect stuff
                Artists.shared.selectedArtist = nil
                Albums.shared.selectedAlbum = nil
                /// Set filters
                Albums.shared.filter = selectedSmartList!.filter
                Songs.shared.filter = selectedSmartList!.filter
            }
        }
    }
    init() {
        /// iOS ignores below
        selectedSmartList = list.first
    }
}
