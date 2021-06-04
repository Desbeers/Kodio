///
/// HeaderView.swift
/// Kodio (iOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var kodi: KodiClient
    @State private var search = ""

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(kodi.player.navigationTitle)
                    .font(.headline)
                Text(kodi.player.navigationSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            ViewPlaylistMenu()
            ViewRadioMenu()
            SearchField(search: $search, kodi: kodi)
                .frame(maxWidth: 300)
        }
        .padding()
        .border(Color.secondary.opacity(0.3))
        .background(Color.secondary.opacity(0.1))
    }
}
