///
/// ViewPlaylist.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewPlaylists (view)

struct ViewPlaylists: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// Grid
    let colums = [
        GridItem(.adaptive(minimum: 200))
    ]
    /// The View
    var body: some View {
        if kodi.playlists.files.isEmpty {
            VStack {
                Text("You do not have any playlists.")
                    .font(.headline)
                    .padding(.top)
                Spacer()
            }
        } else {
            VStack(alignment: .leading) {
                Text("Your playlists on \(kodi.selectedHost.description)")
                    .font(.title)
                    .padding(.top)
                Divider()
                LazyVGrid(columns: colums, alignment: .leading) {
                    ForEach(kodi.playlists.files) { file in
                        Button {
                            kodi.getPlaylistSongs(file: file)
                        } label: {
                            HStack {
                                Label(file.label, systemImage: file.file.hasSuffix(".m3u") ? "list.number" : "list.star")
                                Spacer()
                            }
                        }
                    }
                }
                .buttonStyle(ViewPlayerStyleButton())
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - ViewPlaylistMenu (view)

/// A view with a list of playlists
struct ViewPlaylistMenu: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The view
    var body: some View {
        Menu("Playlists") {
            ForEach(kodi.playlists.files) { file in
                Button(file.label.removeExtension()) {
                    kodi.getPlaylistSongs(file: file)
                }
            }
        }
        .disabled(kodi.playlists.files.isEmpty)
    }
}
