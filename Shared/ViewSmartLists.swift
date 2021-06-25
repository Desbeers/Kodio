///
/// ViewSmartLists.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - SmartMenuFieldsView (View)

struct ViewSmartLists: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of the application
    @EnvironmentObject var appState: AppState
    /// The smart lists
    static var smartMenu = KodiClient.shared.getSmartMenu()
    /// The view
    var opacity: Double {
        if kodi.albums.selected != nil {
            return 0.8
        }
        return 1
    }
    
    var body: some View {
        Text("Smart lists")
            .foregroundColor(.secondary)
        List {
            ForEach(ViewSmartLists.smartMenu) { album in
                NavigationLink(destination: ViewAlbums().onAppear {
                    print("Smart list selected")
                    kodi.filter.albums = album.filter
                    kodi.filter.songs = album.filter
                    //kodi.artists.selected = nil
                    kodi.albums.selected = nil
                    appState.tabs.tabSongPlaylist = .songs
                }) {
                    Label(album.label, systemImage: album.icon)
                }
            }
        }
        .frame(height: 130)
    }
}

// MARK: - ViewSmartListsStyleLabel (label style)

struct ViewSmartListsStyleLabel: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon.frame(width: 20)
            configuration.title
        }
    }
}
