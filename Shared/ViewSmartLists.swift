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
    /// The smart lists
    static var smartMenu = KodiClient.shared.getSmartMenu()
    /// The view
    var body: some View {
        Text("Smart lists")
            .foregroundColor(.secondary)
        List {
            ForEach(ViewSmartLists.smartMenu) { album in
                NavigationLink(destination: ViewAlbums().onAppear {
                    kodi.filter.albums = album.filter
                    kodi.filter.songs = album.filter
                    kodi.albums.selected = nil
                }) {
                    Label(album.label, systemImage: album.icon)
                }
            }
        }
        .frame(height: 130)
    }
}
