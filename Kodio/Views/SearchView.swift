//
//  SearchView.swift
//  Kodio
//
//  Created by Nick Berendsen on 18/07/2022.
//

import SwiftUI

/// The Search View
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
