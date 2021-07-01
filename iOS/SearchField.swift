///
/// SearchField.swift
/// Kodio (iOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct SearchField: UIViewRepresentable {
    @Binding var search: String
    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: SearchField

        init(_ parent: SearchField) {
            self.parent = parent
        }

        // MARK: Text did change

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.search = searchText            
            SearchFieldObserver.shared.searchText = searchText
        }
    }

    func makeCoordinator() -> SearchField.Coordinator {
        return Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchField>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search"
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchField>) {
        uiView.text = search
    }
}
