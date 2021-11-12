//
//  ViewDetails.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View details about the selected media
struct ViewDetails: View {
    /// The ``LibraryItem`` to show
    let item: LibraryItem
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text(item.title)
                        .font(.title2)
                    Text(item.subtitle)
                        .font(.caption)
                    ViewArtwork(media: item)
                    Text(item.description)
                    ViewStatistics(item: item)
                    Spacer()
                }
                .padding()
                .frame(width: 300)
                .id("DetailsHeader")
            }
            /// Scroll to the top when content changed
            .onChange(of: item.id) { _ in
                withAnimation(.easeInOut(duration: 1)) {
                    proxy.scrollTo("DetailsHeader", anchor: .top)
                }
            }
            .animation(.default, value: item.id)
            .transition(.move(edge: .leading))
        }
    }
}

extension ViewDetails {
    
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
}
