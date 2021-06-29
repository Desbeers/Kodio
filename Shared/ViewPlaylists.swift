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
        GridItem(.adaptive(minimum: 210))
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
                        Label(file.label.removeExtension(), systemImage: "music.note.list")
                                                .aspectRatio(contentMode: .fit)
                        .padding()
                        .frame(width: 200, height: 100)
                            .background(Color("SongList"))
                            .cornerRadius(5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5).stroke(Color.accentColor, lineWidth: 1)
                            )
                        .compositingGroup()
                            .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 5)
                    }
                    .padding()
                }
            }
            .buttonStyle(ViewPlaylistsStyleButton())
            Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct ViewPlaylistsStyleButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeInOut(duration: 0.2))
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
