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
    /// The AppState model
    @Environment(AppState.self) private var appState
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// The Browser model
    @Environment(BrowserModel.self) private var browser
    /// The loading status of the View
    @State private var status: ViewStatus = .loading
    /// The body of the `View`
    var body: some View {
        content
            .animation(.default, value: status)
        /// Load the library for the selection
            .task {
                browser.items = .init()
                browser.selection = .init()
                browser.router = appState.selection
                browser.query = appState.query
                await browser.filterLibrary(kodi: kodi)
                await browser.filterBrowser()
                status = browser.items.songs.isEmpty ? .empty : .ready
            }
        /// Filter the browser when a selection has changed
        .onChange(of: browser.selection) {
            if status == .ready {
                Task {
                    await browser.filterBrowser()
                }
            }
        }
        /// Filter the browser when songs are changed
        .onChange(of: kodi.library.songs) {
            Task {
                await browser.filterLibrary(kodi: kodi)
                await browser.filterBrowser()
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
    @ViewBuilder var top: some View {
        HStack(spacing: 0) {
            switch status {
            case .ready:
                GenresView()
                    .frame(width: 150)
                    .padding(.leading, 5)
                ArtistsView()
                AlbumsView()
            default:
                status.message(router: appState.selection)
            }
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
        DetailsView()
        VStack {
            HeaderView()
            SongsView()
        }
        .frame(maxHeight: .infinity)
    }
}
