//
//  ViewLibrary.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewLibrary: View {
    /// The view
    var body: some View {
            VStack(spacing: 0) {
                /// A divider; else the artist and albums fill scroll over the toolbar
                Divider()
                HStack(spacing: 0) {
                    ViewGenres()
                        .frame(width: 200)
                    ViewArtists()
                    ViewAlbums()
                }
                .background(Color.accentColor.opacity(0.05))
                .overlay(
                    ViewDropShadow()
                )
                HStack(spacing: 0) {
                    ViewDetails()
                    ViewSongs()
                }
            }
            .toolbar()
    }
}
