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
    @StateObject private var browser: BrowserModel
    
    private let router: Router
    private let query: String
    
    init(router: Router, query: String = "") {
        _browser = StateObject(wrappedValue: BrowserModel(router: router, query: query))
        self.router = router
        self.query = query
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(iOS)
            Divider()
            #endif
            switch browser.state {
            case .loading:
                if router == .search {
                    PartsView.LoadingState(message: "Seaching for \(query)...")
                } else {
                    PartsView.LoadingState(message: "\(router.sidebar.description)...")
                }
            case .empty:
                if router == .search {
                    PartsView.LoadingState(message: "Nothing found for '\(query)'", icon: router.sidebar.icon)
                } else {
                    PartsView.LoadingState(message: router.empty, icon: router.sidebar.icon)
                }
            case .ready:
                    HStack(spacing: 0) {
                        GenresView()
                            .frame(width: 150)
                            .padding(.leading, 5)
                        ArtistsView()
                        AlbumsView()
                    }
                    /// Just some eyecandy
                    .animation(.default, value: browser.items.songs)
                    .overlay {
                        LinearGradient(gradient: Gradient(stops: [
                            Gradient.Stop(color: Color.black.opacity(0.25), location: 0),
                            Gradient.Stop(color: Color.black.opacity(0.025), location: 0.2),
                            Gradient.Stop(color: Color.clear, location: 1)
                        ]), startPoint: .bottom, endPoint: .top)
                            .blendMode(.multiply)
                            .allowsHitTesting(false)
                    }
                    HStack(alignment: .top) {
                        DetailsView(router: router, selectedItem: browser.details)
                            .animation(.default, value: browser.selection)
                        SongsView()
                    }
                    .animation(.default, value: browser.selection)
            }
        }
        .animation(.default, value: browser.state)
        .environmentObject(browser)
        /// Load the library
        .task(id: kodi.library.songs) {
            browser.filterLibrary()
        }
        /// Filter the browser when a selection has changed
        .onChange(of: browser.selection) { _ in
            browser.filterBrowser()
        }
    }
}
