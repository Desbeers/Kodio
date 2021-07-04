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
        ForEach(smartLists.list) { album in
            NavigationLink(destination: ViewDetails(), tag: album, selection: $smartLists.selectedSmartList) {
                Label(album.label, systemImage: album.icon)
            }
        }
    }
}
