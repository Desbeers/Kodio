//
//  ViewPlayer.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View player bits and pieces

/// The buttons for player start, pause, next and previous
struct ViewPlayerButtons: View {
    /// The Player model
    @EnvironmentObject var player: Player
    /// The Queue model
    @EnvironmentObject var queue: Queue
    /// The view
    var body: some View {
        HStack(spacing: AppState.shared.system == .macOS ? 0 : 20) {
            Button(
                action: {
                    player.sendAction(method: .playerGoTo,
                                      queueID: player.properties.queueID - 1)
                },
                label: {
                    Image(systemName: "backward.fill")
                }
            )
                .disabled(player.properties.queueID <= 0)
            Button(
                action: {
                    player.sendPlayerPlayPause(queue: Library.shared.getSongsFromQueue())
                },
                label: {
                    Image(systemName: player.properties.queueID >= 0 && player.properties.speed == 1 ? "pause.fill" : "play.fill")
                    /// Fixed width because otherwise pause is smaller than play
                        .frame(width: 24)
                }
            )
                .disabled(player.properties.queueID == -1 && queue.queueItems.isEmpty)
            Button(
                action: {
                    player.sendAction(method: .playerGoTo,
                                      queueID: player.properties.queueID + 1)
                },
                label: {
                    Image(systemName: "forward.fill")
                }
            )
                .disabled(player.properties.queueID == -1 || player.properties.queueID >= queue.items)
        }
        /// Button style for enabled or disabled styling
        /// Colors are in mac style; black is enabled; grey disabled
#if os(iOS)
        .buttonStyle(ButtonStylePlayer())
#endif
    }
}

/// A button with mini art to open the queue sheet
struct ViewPlayerQueueButton: View {
    /// The size of the artwork
    var artSize: CGFloat
    /// The Player model
    @EnvironmentObject var player: Player
    /// The view
    var body: some View {
        Button(
            action: {
                AppState.shared.viewSheet(type: .queue)
            },
            label: {
                ViewPlayerArt(item: player.item, size: artSize)
                    .frame(width: artSize, height: artSize)
                    .cornerRadius(2)
            }
        )
            .buttonStyle(PlainButtonStyle())
    }
}

/// The options for shuffle and repeat
struct ViewPlayerOptions: View {
    /// The Player model
    @EnvironmentObject var player: Player
    /// The view
    var body: some View {
        HStack(spacing: AppState.shared.system == .macOS ? 0 : 20) {
            Button(
                action: {
                    player.sendAction(method: .playerSetShuffle)
                },
                label: {
                    Image(systemName: "shuffle")
                        .foregroundColor(player.properties.shuffled ? .accentColor : .primary)
                }
            )
            Button(
                action: {
                    player.sendAction(method: .playerSetRepeat)
                },
                label: {
                    Image(systemName: player.properties.repeatingIcon)
                        .foregroundColor(player.properties.repeating != "off"  ? .accentColor : .primary)
                }
            )
        }
    }
}

/// The slider for volume change
struct ViewPlayerVolume: View {
    /// The KodiHost model
    @EnvironmentObject var kodiHost: KodiHost
    /// The view
    var body: some View {
        HStack {
            Image(systemName: "speaker.wave.3.fill")
            /// - Note: Using 'onEditingChanged' because that will only be trickered when using the slider
            ///         and not when programmaticly changing its value after a notification.
            Slider(value: $kodiHost.volume, in: 0...100,
                   onEditingChanged: { _ in
                logger("Volume changed: \(kodiHost.volume)")
                kodiHost.setVolume(volume: kodiHost.volume)
            })
        }
    }
}

// MARK: - Button styles

/// Button style for a player item on iOS
struct ButtonStylePlayer: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        ViewButtonStylePlayer(configuration: configuration)
    }
}

/// The view for a button style
private extension ButtonStylePlayer {
    
    /// The style of a player button
    struct ViewButtonStylePlayer: View {
        /// Tracks if the button is enabled or not
        @Environment(\.isEnabled) var isEnabled
        /// Tracks the pressed state
        let configuration: ButtonStylePlayer.Configuration
        /// The view
        var body: some View {
            return configuration.label
            /// change the text color if the button is disabled
                .foregroundColor(isEnabled ? .primary : .secondary.opacity(0.6))
                .scaleEffect(1.1)
                .brightness(configuration.isPressed ? 0.2 : 0)
        }
    }
}
