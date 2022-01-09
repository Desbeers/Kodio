//
//  ViewLibraryItem.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// View a row in an ``LibraryItem`` list view
struct ViewLibraryItemListRow: View {
    /// The ``LibraryItem`` to show
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
            ViewLibraryItemDetails(item: item)
        }
    }
}

/// View details for a ``LibraryItem``
struct ViewLibraryItemDetails: View {
    /// The ``LibraryItem`` to show
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
        .lineLimit(1)
    }
}

/// Button style for a library item
struct ButtonStyleLibraryItem: ButtonStyle {
    /// The library item
    let item: LibraryItem
    /// Bool if selected or not
    let selected: Bool
    /// The style
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundColor(.white)
            .background(
                VStack {
                    /// - Note: On iOS, the accentColor for a disabled button is grey, so, force blue
                    if AppState.shared.system == .macOS {
                        Color.accentColor
                    } else {
                        Color.blue
                    }
                }.saturation(selected ? 1 : buttonSaturation(item: item))
            )
            .cornerRadius(6)
            .brightness(configuration.isPressed ? 0.1 : 0)
            .padding(.vertical, 2)
            .padding(.trailing, 8)
    }
    
    /// Saturate a button
    /// - Parameter media: The media type
    /// - Returns: A saturation value
    private func buttonSaturation(item: LibraryItem) -> Double {
        switch item.media {
        case .album:
            return 0.4
        case .artist:
            return 0.25
        case .genre:
            return 0.1
        default:
            return 1.0
        }
    }
}
