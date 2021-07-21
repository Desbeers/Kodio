///
/// ViewSearch.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewSearch (view)

/// For now, macOS and iOS have their own 'native' searchfields because SwiftUI 2.0 does not have that.
struct ViewSearch: View {
    /// The Combine thingy so it is not searching after every typed letter.
    @StateObject var searchObserver = SearchFieldObserver.shared
    /// The view
    var body: some View {
        SearchField(search: $searchObserver.searchText)
    }
}
