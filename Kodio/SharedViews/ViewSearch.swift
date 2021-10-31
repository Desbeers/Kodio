//
//  ViewSearch.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewSearchButton: View {
    /// The object that has it all
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        if !library.search.query.isEmpty {
            Button(
                action: {
                    library.toggleSmartList(smartList: Library.searchButton)
                },
                label: {
                    HStack {
                        Image(systemName: Library.searchButton.icon)
                            .foregroundColor(.accentColor)
                            .frame(width: 16)
                        Text("Search results")
                        Spacer()
                    }
                }
            )
                .disabled(Library.searchButton == library.smartLists.selected)
        }
    }
}

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
                                    .foregroundColor(.primary)
                            }
                        }
                        .searchCompletion(suggestion.suggestion)
                    }
                }
            }
    }
}
