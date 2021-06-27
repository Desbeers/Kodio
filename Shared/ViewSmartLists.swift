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
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The smart lists
    static var smartMenu = KodiClient.shared.getSmartMenu()
    
    @State var selected: SmartMenuFields?
    /// The view
    var body: some View {
        List {
            ForEach(ViewSmartLists.smartMenu) { album in
                NavigationLink(destination: ViewAlbums().onAppear {
                    kodi.filter.albums = album.filter
                    kodi.filter.songs = album.filter
                    appState.selectedAlbum = nil
                },
                tag: album,
                selection: $selected) {
                    Label(album.label, systemImage: album.icon)
                }
            }
            ViewTabArtistsGenres()
        }
        .onAppear {
            selected = ViewSmartLists.smartMenu.first
        }
        .modifier(SmartListsModifier())
    }
}
