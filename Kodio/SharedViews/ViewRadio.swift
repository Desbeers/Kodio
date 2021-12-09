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
        Section(header: Text("Radio Stations")) {
            ForEach(library.radioStations) { channel in
                Button(
                    action: {
                        Task.detached(priority: .userInitiated) {
                            await player.playRadio(stream: channel.stream)
                        }
                    },
                    label: {
                        Label {
                            VStack(alignment: .leading) {
                                Text(channel.title)
                                    .lineLimit(nil)
                                Text(channel.description)
                                    .lineLimit(nil)
                                    .font(.caption)
                                    .opacity(0.5)
                            }
                        } icon: {
                            Image(systemName: radioIcon(channel: channel))
                                .foregroundColor(.purple)
                        }
                    }
                )
            }
        }
        .buttonStyle(.plain)
    }
}

extension ViewRadio {

    /// The SF symbol for the radio item
    /// - Parameter channel: A ``Library/RadioItem`` struct
    /// - Returns: A ``String`` with the name of the SF symbol
    func radioIcon(channel: Library.RadioItem) -> String {
        var icon = "antenna.radiowaves.left.and.right"
        if player.item.mediaPath == channel.stream {
            if player.properties.speed == 0 {
                icon = "pause.fill"
            } else {
                icon = "play.fill"
            }
        }
        return icon
    }
}
