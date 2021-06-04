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
        ForEach(ViewSmartLists.smartMenu) { album in
            HStack {
                Label(album.label, systemImage: album.icon)
                    .foregroundColor(kodi.filter.albums == album.filter ? Color.white : Color.primary)
                Spacer()
            }
            .padding(8)
            /// Make the whole listitem clickable
            .contentShape(Rectangle())
            .onTapGesture(perform: {
                kodi.filter.albums = album.filter
                kodi.filter.songs = album.filter
                kodi.artists.selected = nil
                kodi.albums.selected = nil
                appState.tabs.tabSongPlaylist = .songs
            })
            .if(kodi.filter.albums == album.filter) {
                $0.background(Color.accentColor.opacity(opacity)).foregroundColor(.white)
            }
            .cornerRadius(5)
            .labelStyle(ViewSmartListsStyleLabel())
        }
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
