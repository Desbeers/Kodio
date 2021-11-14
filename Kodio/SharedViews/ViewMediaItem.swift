//
//  ViewMediaItem.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View title, subtitle and details of a ``MediaItem``
struct ViewMediaItem: View {
    /// The ``MediaItem`` to show
    let item: LibraryItem
    /// The view
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.title)
                .font(.headline)
            if !item.subtitle.isEmpty {
                Text(item.subtitle)
                    .font(.subheadline)
                    .opacity(0.6)
            }
            if !item.details.isEmpty {
                Text(item.details)
                    .font(.caption)
                    .opacity(0.4)
            }
        }
    }
}
