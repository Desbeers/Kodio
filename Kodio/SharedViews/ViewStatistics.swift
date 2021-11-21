//
//  ViewStatistics.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View statistics for the current library view
struct ViewStatistics: View {
    /// The current ``LibraryItem``
    let item: LibraryItem
    /// The Library model
     @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        if !library.filteredContent.songs.isEmpty {
            VStack {
                switch item.media {
                case .none:
                    EmptyView()
                case .artist:
                    songsCount
                    albumsCount
                case .album:
                    songsCount
                default:
                    songsCount
                    albumsCount
                    artistsCount
                }
            }
            .labelStyle(LabelStyleStatistics())
        } else {
            EmptyView()
        }
    }
    /// Songs in the current library view
    var songsCount: some View {
        Label {
            let songs = library.filteredContent.songs.count
            Text("\(songs) " + (songs == 1 ? "song" : "songs"))
        } icon: {
            Image(systemName: "music.quarternote.3")
        }
    }
    /// Albums in the current library view
    var albumsCount: some View {
        Label {
            let albums = library.filteredContent.albums.count
            Text("\(albums) " + (albums == 1 ? "album" : "albums"))
        } icon: {
            Image(systemName: "square.stack")
        }
    }
    /// Artists in the current library view
    var artistsCount: some View {
        Label {
            let artists = library.filteredContent.artists.count
            Text("\(artists) " + (artists == 1 ? "artist" : "artists"))
        } icon: {
            Image(systemName: "person.2")
        }
    }
}

extension ViewStatistics {
    
    /// The style for a 'statistic' label
    struct LabelStyleStatistics: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack {
                configuration.icon
                    .frame(width: 20, alignment: .center)
                    .foregroundColor(.accentColor)
                configuration.title
                    .frame(maxWidth: 100, alignment: .leading)
            }
            .padding(.vertical, 2)
        }
    }
}
