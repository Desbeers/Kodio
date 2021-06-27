///
/// ViewAlbums.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewAlbums (view)

/// The main albums view
struct ViewAlbums: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            List {
                ViewArtFanart()
                // Text(kodi.albumListID)
                ForEach(kodi.albumsFilter) { album in
                    NavigationLink(destination: ViewDetails(), tag: album, selection: $appState.selectedAlbum) {
                        ViewAlbumsListRow(album: album)
                    }
                }
                if appState.selectedArtist != nil, !(appState.selectedArtist?.description.isEmpty ?? true) {
                    HStack {
                        Spacer()
                        Button("More about '\(appState.selectedArtist!.artist)'") {
                            DispatchQueue.main.async {
                                appState.activeSheet = .viewArtistInfo
                                appState.showSheet = true
                            }
                        }
                    }
                }
            }
            .id(kodi.albumListID)
            .onChange(of: kodi.libraryJump) { item in
                proxy.scrollTo(item.albumID, anchor: .top)
            }
            .modifier(DetailsModifier())
        }
    }
}

// MARK: - ViewAlbumsListRow (view)

/// The row of an album in the list
struct ViewAlbumsListRow: View {
    var album: AlbumFields
    /// The view
    var body: some View {
        HStack {
            ViewArtAlbum(album: album)
            VStack(alignment: .leading) {
                Text(album.title)
                    .font(.headline)
                Group {
                    Text(album.artist.joined(separator: " & "))
                    /// Hide details when there is no year
                    if album.year != 0 {
                        HStack(spacing: 0) {
                            Text(String(album.year))
                            Text("∙")
                            Text(album.genre.first ?? "")
                        }
                    }
                }
                .font(.caption)
            }
            Spacer()
        }
        .id(album.albumID)
    }
}
