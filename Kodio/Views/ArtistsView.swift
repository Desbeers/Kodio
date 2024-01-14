//
//  GenresView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the artists
struct ArtistsView: View {
    /// The Browser model
    @Environment(BrowserModel.self)
    private var browser
    /// The sorting
    private let sorting = SwiftlyKodiAPI.List.Sort(id: "artists", method: .title, order: .ascending)
    /// The collection
    @State private var collection: ScrollCollection<AnyKodiItem> = []
    /// The body of the `View`
    var body: some View {
        ScrollCollectionView(
            collection: collection,
            style: .asList,
            anchor: .top,
            showIndex: false,
            header: { header in
                PartsView.BrowserHeader(
                    label: "Artists",
                    index: header.sectionLabel,
                    padding: 8
                )
            },
            cell: { _, item in
                if let artist = item.item as? Audio.Details.Artist {
                    Button(action: {
                        withAnimation {
                            browser.selection.artist = browser.selection.artist == artist ? nil : artist
                            browser.selection.album = nil
                        }
                    }, label: {
                        HStack {
                            KodiArt.Poster(item: artist)
                                .cornerRadius(4)
                                .frame(width: 58, height: 58)
                                .padding(2)
                            VStack(alignment: .leading) {
                                Text(artist.title)
                                Text(artist.subtitle)
                                    .lineLimit(1)
                                    .font(.subheadline)
                                    .opacity(0.8)
                            }
                        }
                    })
                    .buttonStyle(ButtonStyles.Browser(item: artist, selected: browser.selection.artist == artist))
                }
            }
        )
        .task(id: browser.items.artists) {
            collection = Utils.groupKodiItems(items: browser.items.artists, sorting: sorting)
        }
    }
}
