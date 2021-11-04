//
//  ViewSearch.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewModifierSearch: ViewModifier {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The Combine thingy so it is not searching after every typed letter
    @StateObject var searchObserver: SearchObserver = .shared
    /// The view
    func body(content: Content) -> some View {
        content
            .searchable(text: $searchObserver.searchText) {
                if !library.search.suggestions.isEmpty {
                    ForEach(library.search.suggestions) { suggestion in
                        HStack {
                            RemoteArt(url: suggestion.thumbnail)
                                .frame(width: 30, height: 30)
                            VStack(alignment: .leading) {
                                Text(suggestion.title)
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
