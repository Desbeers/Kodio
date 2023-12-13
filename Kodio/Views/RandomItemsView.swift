//
//  RandomItemsView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` with random items from the library
struct RandomItemsView: View {
    /// The randon albums
    @State private var albums: [Audio.Details.Album] = []
    /// Bool to show the confirmation dialog
    @State private var showConfirmation = false
    /// The optional selected album
    @State private var selectedAlbum: Audio.Details.Album?
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// The body of the `View`
    var body: some View {
        Button(action: {
            getRandomAlbums()
        }, label: {
            Text("Random Albums")
        })
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(albums) { album in
                    Button(action: {
                        selectedAlbum = album
                        showConfirmation = true
                    }, label: {
                        KodiArt.Poster(item: album)
                            .frame(height: 180)
                    })
                    .scrollTransition(.animated) { content, phase in
                        content
                            .opacity(phase != .identity ? 0.3 : 1)
                    }
                }
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .contentMargins(.horizontal, 10, for: .scrollContent)
        .animation(.default, value: albums)
        .background(.thickMaterial)
        .buttonStyle(.plain)
        .task {
            getRandomAlbums()
        }
        .confirmationDialog(
            selectedAlbum?.artist.joined(separator: " ・ ") ?? "Play Album",
            isPresented: $showConfirmation
        ) {
            if let selectedAlbum {
                Button("Play") {
                    playAlbum(album: selectedAlbum, shuffle: false)
                }
                Button("Shuffle") {
                    playAlbum(album: selectedAlbum, shuffle: true)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(selectedAlbum?.title ?? "No album selected")
        }
    }

    /// Play a random album
    /// - Parameters:
    ///   - album: The selected album
    ///   - shuffle: Bool to shuffle the album or not
    private func playAlbum(album: Audio.Details.Album, shuffle: Bool) {
        let songs = kodi.library.songs.filter { $0.albumID == album.albumID } .sorted(using: KeyPathComparator(\.track))
        KodioSettings.setPlayerSettings(media: .album)
        songs.play(shuffle: shuffle)
    }

    /// Get random items from the library
    private func getRandomAlbums() {
        albums = Array(Set(kodi.library.albums).prefix(10))
    }
}
