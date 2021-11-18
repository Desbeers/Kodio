//
//  ViewMediaItem.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View a row in an ``MediaItem`` list view
struct ViewMediaItemListRow: View {
    /// The ``MediaItem`` to show
    let item: LibraryItem
    /// The size of the thumbnail
    let size: CGFloat
    /// The view
    var body: some View {
        HStack {
            ViewRemoteArt(item: item, art: .thumbnail)
                .cornerRadius(4)
                .frame(width: size, height: size)
                .padding(2)
            ViewMediaItemDetails(item: item)
        }
    }
}

/// View details for a ``MediaItem``
struct ViewMediaItemDetails: View {
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
                    .opacity(0.8)
            }
            if !item.details.isEmpty {
                Text(item.details)
                    .font(.caption)
                    .opacity(0.6)
            }
        }
    }
}

/// View modifier for lists
struct ViewModifierLists: ViewModifier {
#if os(macOS)
    func body(content: Content) -> some View {
        content
    }
#endif
#if os(iOS)
    func body(content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
    }
#endif
}
