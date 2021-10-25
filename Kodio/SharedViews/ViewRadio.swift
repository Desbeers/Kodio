//
//  ViewRadio.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewRadio: View {
    /// The object that has it all
    @EnvironmentObject var library: Library
    /// The player object
    @EnvironmentObject var player: Player
    /// The view
    var body: some View {
        Section(header: Text("Radio stations")) {
            ForEach(library.radioStations) { channel in
                Button(
                    action: {
                        Player.shared.playRadio(stream: channel.stream)
                    },
                    label: {
                        ViewRadioLabel(channel: channel)
                    }
                )
            }
        }
    }
}

private extension ViewRadio {
    struct ViewRadioLabel: View {
        /// The player object
        @EnvironmentObject var player: Player
        /// The radio channel
        var channel: Library.RadioItem
        /// The view
        var body: some View {
            Label(channel.label, systemImage: player.item.mediapath == channel.stream ? player.properties.speed == 1 ? "play.fill" : "pause.fill" : "antenna.radiowaves.left.and.right")
        }
    }
}
