///
/// ViewDescription.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

/// Show a description about artist or album
struct ViewDescription: View {
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The object
    var artist: ArtistFields?
    var album: AlbumFields?
    /// The view
    var body: some View {
        VStack {
            
            switch appState.activeSheet {
            case .viewArtistInfo:
                Text(artist!.artist)
                    .font(.title)
                ScrollView {
                    Text(artist!.description)
                        .padding()
                }
            case .viewAlbumInfo:
                Text(album!.title)
                    .font(.title)
                Text(album!.artist.first!)
                    .font(.title2)
                ScrollView {
                    Text(album!.description)
                        .padding()
                }
            case .editHosts:
                Text("This will not happen")
            }
            Button("Close") {
                DispatchQueue.main.async {
                    appState.showSheet = false
                }
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding()
        .frame(idealWidth: 500, idealHeight: 500)
    }
}
