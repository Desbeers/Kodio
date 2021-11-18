//
//  ViewDetails.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View details about the selected ``LibraryItem``
struct ViewDetails: View {
    /// The ``LibraryItem`` to show
    let item: LibraryItem
    /// The view
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Group {
                        Text(item.title)
                            .font(.title2)
                            .lineLimit(1)
                        Text(item.subtitle)
                            .font(.caption)
                    }
                    .id(item.title)
                    ViewArtwork(item: item)
                    Text(item.description)
                    ViewStatistics(item: item)
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
            .animation(.default, value: item.description)
            .transition(.slide)
        }
    }
}

extension ViewDetails {
    
    /// View artwork for the selected media
    struct ViewArtwork: View {
        /// The selected ``LibraryItem``
        let item: LibraryItem
        /// The view
        var body: some View {
            VStack {
                RadialGradient(gradient: Gradient(colors: [.accentColor, .black]), center: .center, startRadius: 0, endRadius: 280)
                    .saturation(0.4)
                    .overlay(
                        overlay
                    )
            }
            .animation(.none, value: item.id)
            .cornerRadius(3)
            .frame(width: 256, height: 144)
        }
        /// Overlay the base artwork
        @ViewBuilder var overlay: some View {
            switch item.media {
            case .artist:
                ViewRemoteArt(item: item, art: .fanart)
                    .cornerRadius(2)
                    .padding(1)
            case .album:
                ZStack {
                    ViewRotatingRecord()
                        .frame(width: 175, height: 145, alignment: .trailing)
                    ViewRemoteArt(item: item, art: .thumbnail)
                        .scaledToFit()
                        .cornerRadius(2)
                        .frame(width: 254, height: 142, alignment: .leading)
                }
                .cornerRadius(2)
                .padding(1)
            default:
                Image(systemName: item.icon)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(radius: 20)
            }
        }
    }
}
