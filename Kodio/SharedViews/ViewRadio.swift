//
//  ViewRadio.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI


/// A list with radio channels
struct ViewRadio: View {
    /// The Library object
    @EnvironmentObject var library: Library
    /// The player object
    @EnvironmentObject var player: Player
    /// The view
    var body: some View {
        Section(header: Text("Radio stations")) {
            ForEach(library.radioStations) { channel in
                Button(
                    action: {
                        player.playRadio(stream: channel.stream)
                    },
                    label: {
                        radioLabel(channel: channel)
                    }
                )
            }
        }
    }
}

extension ViewRadio {

    /// Create a `Label` for a radio channel
    /// - Parameter channel: the `RadioItem` struct
    /// - Returns: a formatted `Label`
    @ViewBuilder func radioLabel(channel: Library.RadioItem) -> some View {
        if player.item.mediapath == channel.stream {
            if player.properties.speed == 0 {
                Label(channel.label, systemImage: "pause.fill")
            } else {
                Label(channel.label, systemImage: "play.fill")
            }
        } else {
            Label(channel.label, systemImage: "antenna.radiowaves.left.and.right")
        }
    }
}
