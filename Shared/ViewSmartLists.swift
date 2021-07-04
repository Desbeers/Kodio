///
/// ViewSmartLists.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - SmartMenuFieldsView (View)

struct ViewSmartLists: View {
    /// The smart list object
    @StateObject var smartLists: SmartLists = .shared
    /// The view
    var body: some View {
        List {
            ForEach(smartLists.list) { album in
                NavigationLink(destination: ViewAlbums(), tag: album, selection: $smartLists.selectedSmartList) {
                    Label(album.label, systemImage: album.icon)
                }
            }
            ViewTabsSidebar()
        }
        .onAppear {
            /// Bug: iOS got upset when doing below. When hiding the sidebar,
            /// this is triggered on refresh of the UI even thought the sidebar is not visible.
            if KodiClient.shared.userInterface == .macOS {
                smartLists.selectedSmartList = smartLists.list.first
            }
        }
        /// Different heights for macOS and iOS.
        /// I have to set the height because the list is dynamic and will use 50% of the height by default.
        .frame(height: KodiClient.shared.userInterface == .macOS ? 168 : 280)
    }
}
