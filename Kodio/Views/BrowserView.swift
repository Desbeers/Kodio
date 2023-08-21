//
//  BrowserView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the browser
struct BrowserView: View {
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The Browser model
    @StateObject private var browser: BrowserModel
    /// All the items for this View
    @State var items = BrowserModel.Media()
    /// The ``Router`` item
    private let router: Router
    /// The search query
    private let query: String
    /// Init the view
    init(router: Router, query: String = "") {
        _browser = StateObject(wrappedValue: BrowserModel(router: router, query: query))
        self.router = router
        self.query = query
    }
    /// The body of the `View`
    var body: some View {
        VStack {
            switch browser.state {
            case .loading:
                if router == .search {
                    PartsView.LoadingState(message: "Seaching for \(query)...")
                }
            case .empty:
                if router == .search {
                    PartsView.LoadingState(message: "Nothing found for '\(query)'", icon: router.item.icon)
                } else {
                    PartsView.LoadingState(message: router.item.empty, icon: router.item.icon)
                }
            case .ready:
                content
            }
        }
        /// Just some eyecandy
        .animation(.default, value: browser.selection)
        /// Load the library
        .task(id: router) {
            await browser.filterLibrary()
            items = await browser.filterBrowser()
            browser.state = items.songs.isEmpty ? .empty : .ready
        }
        /// Filter the browser when a selection has changed
        .onChange(of: browser.selection) { _ in
            Task {
                items = await browser.filterBrowser()
            }
        }
        /// Filter the browser when songs are changed
        .onChange(of: kodi.library.songs) { _ in
            Task {
                await browser.filterLibrary()
                items = await browser.filterBrowser()
            }
        }
    }

    /// The content of the `View`
    @ViewBuilder var content: some View {
#if os(macOS)
        VSplitView {
            top
            HSplitView {
                bottom
            }
        }
#endif

#if os(visionOS) || os(iOS)
        VStack {
            /// Dont scroll the lists over the toolbar
            Divider().opacity(0)
            top
            HStack {
                bottom
            }
        }
#endif
    }

    /// The top part of the `View`
    var top: some View {
        HStack(spacing: 0) {
            GenresView(genres: items.genres, selection: $browser.selection)
                .frame(width: 150)
                .padding(.leading, 5)
            ArtistsView(artists: items.artists, selection: $browser.selection)
            AlbumsView(albums: items.albums, selectedAlbum: $browser.selection.album)
        }
        .overlay {
            LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: Color.black.opacity(0.25), location: 0),
                    Gradient.Stop(color: Color.black.opacity(0.025), location: 0.2),
                    Gradient.Stop(color: Color.clear, location: 1)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
        }
    }

    /// The bottom part of the `View`
    @ViewBuilder var bottom: some View {
        DetailsView(router: router, selectedItem: browser.details)
        VStack {
            HeaderView(songs: $items.songs, selectedAlbum: browser.selection.album)
            SongsView(songs: items.songs, selectedAlbum: browser.selection.album)
        }
    }
}
