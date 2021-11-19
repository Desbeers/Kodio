//
//  ViewSearch.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// A ``ViewModifier`` to add the search field
struct ViewModifierSearch: ViewModifier {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The Combine thingy so it is not searching after every typed letter
    @StateObject var searchObserver: SearchObserver = .shared
    /// The view
    func body(content: Content) -> some View {
        content
        /// - Note: To make it possible to change the button layout of the toolbar in macOS
        /// the 'search' **must** be in the sidebar or else it does not work
            .searchable(text: $searchObserver.query, placement: .sidebar, prompt: "Search library") {
                if !appState.filteredContent.searchSuggestions.isEmpty {
                    ForEach(appState.filteredContent.searchSuggestions) { suggestion in
                        HStack {
                            VStack(alignment: .leading) {
                                Label(suggestion.title, systemImage: suggestion.icon)
                                Text(suggestion.subtitle)
                                    .font(.caption)
                                    .opacity(0.8)
                            }
                        }
                        .searchCompletion(suggestion.suggestion)
                    }
                }
            }
    }
}
