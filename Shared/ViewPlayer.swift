///
/// ViewPlayer.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ViewPlayerItem: View {
    /// The object that has it all:
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The View
    var body: some View {
        VStack {
            HStack {
                Text(kodi.player.navigationTitle)
                    .font(.headline)
                Text(kodi.player.navigationSubtitle)
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - ViewPlayerButtons (view)

/// The buttons for player start, pause, next and previous
struct ViewPlayerButtons: View {
    /// The object that has it all:
    @EnvironmentObject var kodi: KodiClient
    /// The view
    var body: some View {
        Button(
            action: {
                kodi.sendPlayerAction(api: .playerGoTo,
                                      playlistPosition: kodi.player.properties.playlistPosition - 1)
            },
            label: {
                Image(systemName: "backward.fill")
            }
        )
        .disabled(kodi.player.item.songID == nil || kodi.player.properties.playlistPosition == 0)
        Button(
            action: {
                kodi.sendPlayerPlayPause()
            },
            label: {
                Image(systemName: kodi.player.properties.speed == 1 ? "pause.fill" : "play.fill")
            }
        )
        .disabled(kodi.player.item.type != "song")
        Button(
            action: {
                kodi.sendPlayerAction(api: .playerGoTo,
                                      playlistPosition: kodi.player.properties.playlistPosition + 1)
            },
            label: {
                Image(systemName: "forward.fill")
            }
        )
        .disabled(kodi.player.item.songID == nil ||
                    kodi.player.properties.playlistPosition == kodi.player.playlistItems)
    }
}
    
// MARK: - ViewPlayerOptions (view)

/// The options for shuffle and repeat
struct ViewPlayerOptions: View {
    /// The object that has it all:
    @EnvironmentObject var kodi: KodiClient
    /// The view
    var body: some View {
        Button(
            action: {
                kodi.sendPlayerAction(api: .playerSetShuffle)
            },
            label: {
                Image(systemName: "shuffle")
                    .foregroundColor(kodi.player.properties.shuffled ? .accentColor : .primary)
            }
        )
        Button(
            action: {
                kodi.sendPlayerAction(api: .playerSetRepeat)
            },
            label: {
                Image(systemName: kodi.player.properties.repeatingIcon)
                    .foregroundColor(kodi.player.properties.repeating != "off"  ? .accentColor : .primary)
            }
        )
    }
}

// MARK: - ViewPlayerVolume (view)

/// The options for shuffle and repeat
struct ViewPlayerVolume: View {
    /// The object that has it all:
    @EnvironmentObject var kodi: KodiClient
    /// The view
    var body: some View {
        HStack {
            Image(systemName: "speaker.wave.3.fill")
        Slider(value: $kodi.properties.volume, in: 0...100)
            .onChange(of: kodi.properties.volume, perform: { value in
                kodi.setApplicationVolume(volume: value)
            })
        }
    }
}

// MARK: - ViewPlayerStyleButton: (button style)

struct ViewPlayerStyleButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        ViewPlayerStyleButtonView(configuration: configuration)
    }
}

extension ViewPlayerStyleButton {
    struct ViewPlayerStyleButtonView: View {
        /// tracks if the button is enabled or not
        @Environment(\.isEnabled) var isEnabled
        /// tracks the pressed state
        let configuration: ViewPlayerStyleButton.Configuration
        var body: some View {
            return configuration.label
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .foregroundColor(isEnabled ? .accentColor : .secondary)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5).stroke(Color.secondary.opacity(0.1), lineWidth: 1)
                )
                .scaleEffect(configuration.isPressed ? 0.9 : 1)
        }
    }
}
