///
/// ViewPlaylist.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

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
