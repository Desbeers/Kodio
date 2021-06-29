///
/// ViewSmartLists.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - SmartMenuFieldsView (View)

struct ViewSmartLists: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The smart lists
    static var smartMenu = KodiClient.shared.getSmartMenu()
    /// The view
    var body: some View {
        List {
            ForEach(ViewSmartLists.smartMenu) { album in
                NavigationLink(destination: ViewAlbums(), tag: album, selection: $appState.selectedSmartList) {
                    Label(album.label, systemImage: album.icon)
                }
            }
            ViewTabsSidebar()
        }
        .onAppear {
            /// Bug: iOS got upset when doing below. When hiding the sidebar,
            /// this is triggered on refresh of the UI even thought the sidebar is not visible.
            if kodi.userInterface == .macOS {
                appState.selectedSmartList = ViewSmartLists.smartMenu.first
            }
        }
        /// Different heights for macOS and iOS.
        /// I have to set the height because the list is dynamic and will use 50% of the height by default.
        .frame(height: kodi.userInterface == .macOS ? 168 : 280)
    }
}
