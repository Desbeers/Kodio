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
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// The body of the `View`
    var body: some View {
        VStack {
            Button(action: {
                Task { @MainActor in
                    albums = getRandomAlbums
                }
            }, label: {
                Text("Random Albums")
            })
            .padding([.top, .leading])
            .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(albums) { album in
                        KodiArt.Poster(item: album)
                            .frame(height: 140)
                            .albumOptions(album)
                            .scrollTransition(.animated) { content, phase in
                                content
                                    .opacity(phase != .identity ? 0.3 : 1)
                            }
                    }
                }
            }
            .frame(height: 160)
            .background(.thinMaterial)
        }
        .frame(maxWidth: .infinity)
        .contentMargins(.horizontal, 10, for: .scrollContent)
        .animation(.default, value: albums)
        .buttonStyle(.plain)
        .task(id: kodi.status) {
            albums = kodi.status == .loadedLibrary ? getRandomAlbums : []
        }
    }

    /// Get random items from the library
    private var getRandomAlbums: [Audio.Details.Album] {
        Array(Set(kodi.library.albums).prefix(20))
    }
}

private struct AlbumOptions: ViewModifier {
    let album: Audio.Details.Album
    @Environment(KodiConnector.self) private var kodi
    @State private var showOptions: Bool = false
    @State private var opacity: Double = 0
    func body(content: Content) -> some View {
        Button(
            action: {
                showOptions.toggle()
            },
            label: {
                content
            }
        )
        .opacity(opacity)
        .task {
            try? await Task.sleep(for: .seconds(0.4))
            opacity = 1
        }
        .animation(.default, value: opacity)
        .popover(
            isPresented: self.$showOptions,
            attachmentAnchor: .point(.top),
            arrowEdge: .top
        ) {
            VStack {
                Text(album.title)
                    .font(.headline)
                Text(album.artist.joined(separator: "・"))
                    .font(.subheadline)
                Divider()
                    .padding(.bottom)
                Button(
                    action: {
                        playAlbum(album: album, shuffle: false)
                        showOptions = false
                    },
                    label: {
                        Label("Play album", systemImage: "play.fill")
                    }
                )
                .padding(.bottom)
                Button(
                    action: {
                        playAlbum(album: album, shuffle: true)
                        showOptions = false
                    },
                    label: {
                        Label("Shuffle album", systemImage: "shuffle")
                    }
                )
            }
            .padding()
            .buttonStyle(.plain)
        }
    }


    /// Play a random album
    /// - Parameters:
    ///   - album: The selected album
    ///   - shuffle: Bool to shuffle the album or not
    private func playAlbum(album: Audio.Details.Album, shuffle: Bool) {
        let songs = kodi.library.songs
            .filter { $0.albumID == album.albumID }
            .sorted(using: KeyPathComparator(\.track))
        KodioSettings.setPlayerSettings(media: .album)
        songs.play(host: kodi.host, shuffle: shuffle)
    }
}

private extension View {
    func albumOptions(_ album: Audio.Details.Album) -> some View { modifier(AlbumOptions(album: album)) }
}
