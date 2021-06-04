///
/// ViewDescription.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

/// Show a description about artist or album
struct ViewDescription: View {
    /// Show long description or not
    @State private var showDescription: Bool = false
    /// The actual description
    var description: String
    /// The view
    var body: some View {
        HStack(alignment: .top) {
            Button { withAnimation { showDescription.toggle() } }
                label: {
                    Image(systemName: showDescription ? "chevron.up" : "chevron.down")
            }
            .padding(.leading)
            .padding(.top)
            ScrollView {
                Text(description)
                    .padding()
            }
        }
        .padding(.bottom)
        .if(!showDescription) { $0.frame(maxHeight: 66) }
    }
}
