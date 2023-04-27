//
//  BrowserView.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Browser View
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
        VSplitView {
            switch browser.state {
            case .loading:
                if router == .search {
                    PartsView.LoadingState(message: "Seaching for \(query)...")
                }
            case .empty:
                if router == .search {
                    PartsView.LoadingState(message: "Nothing found for '\(query)'", icon: router.sidebar.icon)
                } else {
                    PartsView.LoadingState(message: router.empty, icon: router.sidebar.icon)
                }
            case .ready:
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
                HSplitView {
                    DetailsView(router: router, selectedItem: browser.details)
                    SongsView(songs: items.songs, selection: $browser.selection)
                }
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
}
