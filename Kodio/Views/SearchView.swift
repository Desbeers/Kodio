//
//  SearchView.swift
//  Kodio
//
//  Created by Nick Berendsen on 18/07/2022.
//

import SwiftUI

/// The Search View
struct SearchView: View {
    let query: String
    var body: some View {
        VStack {
            Text("Search")
                .font(.title)
            Text(query)
        }
    }
}
