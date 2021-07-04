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
                NavigationLink(destination: ViewDetails(), tag: album, selection: $smartLists.selectedSmartList) {
                    Label(album.label, systemImage: album.icon)
                }
            }
            ViewTabsSidebar()
        }
        /// Different heights for macOS and iOS.
        /// I have to set the height because the list is dynamic and will use 50% of the height by default.
        .frame(height: AppState.shared.userInterface == .macOS ? 168 : 280)
    }
}
