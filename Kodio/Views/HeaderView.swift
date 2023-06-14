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
    /// The songs for this `View`
    @Binding var songs: [Audio.Details.Song]
    /// The optional selected album
    let selectedAlbum: Audio.Details.Album?
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
        .buttonStyle(ButtonStyles.Play())
        .padding(.top)
    }
    /// Play the songs in the  current list
    /// - Parameter shuffle: Bool to shuffle the list or not
    func playSongs(shuffle: Bool) {
        var media: KodioSettings.Crossfade = .playlist
        if let selectedAlbum {
            media = selectedAlbum.compilation ? .compilation : .album
        }
        KodioSettings.setPlayerSettings(media: media)
        songs.play(shuffle: shuffle)
    }
}
