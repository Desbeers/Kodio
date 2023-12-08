//
//  DetailsView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the details
struct DetailsView: View {
    /// The AppState model
    @Environment(AppState.self) private var appState
    /// The Browser model
    @Environment(BrowserModel.self) private var browser
    /// Rotate the record
    @State private var rotate: Bool = false
    /// The body of the `View`
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                Text(browser.details?.title ?? appState.selection.item.title)
                    .font(.title2)
                    .lineLimit(1)
                    .padding(.top)
                    .id("Title")
                    .task(id: browser.details?.id) {
                        proxy.scrollTo("Title", anchor: .top)
                    }
                Text(browser.details?.subtitle ?? appState.selection.item.description)
                    .font(.caption)
                VStack {
                    RadialGradient(
                        gradient: Gradient(colors: [.accentColor, .black]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                    .saturation(0.4)
                    .overlay(
                        overlay
                            .scaledToFill()
                            .foregroundColor(.white)
                    )
                }
                .aspectRatio(1.78, contentMode: .fit)
                .cornerRadius(3)
                Text(browser.details?.description ?? "")
                    .padding(.bottom)
            }
            .padding(.horizontal)
        }
    }

    /// Overlay the base artwork
    @ViewBuilder var overlay: some View {
        if let item = browser.details {
            switch item.media {
            case .artist:
                KodiArt.Fanart(item: item)
            case .album:
                ZStack {
                    HStack {
                        Color.clear
                        PartsView.RotatingRecord(
                            title: item.title,
                            subtitle: item.subtitle,
                            details: item.details,
                            rotate: .constant(true)
                        )
                    }
                    HStack {
                        KodiArt.Poster(item: item)
                            .scaledToFit()
                            .cornerRadius(2)
                            .padding(.leading)
                        Color.clear
                    }
                }
                .cornerRadius(2)
                .padding(1)
            default:
                EmptyView()
            }
        } else {
            Image(systemName: appState.selection.item.icon)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 20)
        }
    }
}
