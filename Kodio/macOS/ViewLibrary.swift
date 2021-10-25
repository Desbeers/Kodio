//
//  ViewLibrary.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View content

/// View the whole library
struct ViewLibrary: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        VStack(spacing: 0) {
            SplitView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .frame(maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
    }
}

/// View the top of the library: genres, artists and songs
struct ViewLibraryTop: View {
    /// The view
    var body: some View {
        HStack(spacing: 0) {
            ViewGenres()
                .frame(width: 150)
            ViewArtists()
            ViewAlbums()
        }
        .overlay(
            ViewDropShadow()
        )
    }
}

/// View the bottom of the library: details and the songs
struct ViewLibraryBottom: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        HStack(spacing: 0) {
            ViewDetails()
            Divider()
            ViewSongs()
        }
    }
}
