//
//  SearchView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI

/// SwiftUI `View` for the search
struct SearchView: View {
    /// The search query
    let query: String
    /// The body of the `View`
    var body: some View {
        VStack {
            Text("Search")
                .font(.title)
            Text(query)
        }
    }
}
