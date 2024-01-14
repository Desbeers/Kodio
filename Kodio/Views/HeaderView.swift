//
//  HeaderView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the header
struct HeaderView: View {
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// The Browser model
    @Environment(BrowserModel.self) private var browser
    /// The body of the `View`
    var body: some View {
        HStack {
            Button(action: {
                playSongs(shuffle: false)
            }, label: {
                Label("Play songs", systemImage: "play.fill")
            })
            Button(action: {
                playSongs(shuffle: true)
            }, label: {
                Label("Shuffle songs", systemImage: "shuffle")
            })
        }
        .playButtonStyle()
        .padding(.top)
        .disabled(browser.items.songs.isEmpty)
    }
    /// Play the songs in the  current list
    /// - Parameter shuffle: Bool to shuffle the list or not
    func playSongs(shuffle: Bool) {
        var media: KodioSettings.Crossfade = .playlist
        if let selectedAlbum = browser.selection.album {
            media = selectedAlbum.compilation ? .compilation : .album
        }
        KodioSettings.setPlayerSettings(host: kodi.host, media: media)
        browser.items.songs.play(host: kodi.host, shuffle: shuffle)
    }
}
