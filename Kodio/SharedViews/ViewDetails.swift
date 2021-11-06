//
//  ViewDetails.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View details about the selected media
struct ViewDetails: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ViewMedia(media: library.selection)
                }
                .id("DetailsHeader")
            }
            /// Scroll to the top when content changed
            .onChange(of: library.selection.id) { _ in
                withAnimation(.easeInOut(duration: 1)) {
                    proxy.scrollTo("DetailsHeader", anchor: .top)
                }
            }
            .animation(.default, value: library.selection.id)
            .transition(.move(edge: .leading))
        }
    }
}

extension ViewDetails {
    
    /// View details about the selected media
    struct ViewMedia: View {
        /// The selected media item
        let media: LibraryItem
        /// The view
        var body: some View {
            VStack {
                Text(media.title)
                    .font(.title2)
                Text(media.subtitle)
                    .font(.caption)
                ViewArtwork(media: media)
                Text(media.description)
                ViewStatistics(media: media)
                Spacer()
            }
            .padding()
            .frame(width: 300)
        }
    }
    
    /// View artwork for the selected media
    struct ViewArtwork: View {
        /// The selected media item
        let media: LibraryItem
        /// The view
        var body: some View {
            VStack {
                RadialGradient(gradient: Gradient(colors: [.accentColor, .black]), center: .center, startRadius: 0, endRadius: 280)
                    .saturation(0.4)
                    .overlay(
                        overlay
                    )
            }
            .animation(.none, value: media.id)
            .cornerRadius(3)
            .frame(width: 256, height: 144)
        }
        /// Overlay the base artwork
        @ViewBuilder var overlay: some View {
            switch media.media {
            case .artist:
                RemoteArt(url: media.fanart, failure: Image(systemName: media.icon))
                    .cornerRadius(2)
                    .padding(1)
            case .album:
                ZStack {
                    HStack(alignment: .top) {
                        ViewRotatingRecord()
                            .frame(width: 150, height: 150)
                            .padding(.leading, 68)
                        Spacer()
                    }
                    HStack(alignment: .center) {
                        RemoteArt(url: media.thumbnail, failure: Image(systemName: media.icon))
                            .frame(width: 142, height: 142)
                            .cornerRadius(2)
                        Spacer()
                    }
                }
                .cornerRadius(2)
                .padding(1)
            default:
                Image(systemName: media.icon)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(radius: 20)
            }
        }
    }
    
    /// View statistics for the current library view
    struct ViewStatistics: View {
        /// The selected media item
        let media: LibraryItem
        /// The Library model
        @EnvironmentObject var library: Library
        /// The view
        var body: some View {
            VStack {
                switch media.media {
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
