//
//  ViewToolbar.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View the Toolbar or a part of it
struct ViewToolbar: ViewModifier {
    /// The Player model
    @EnvironmentObject var player: Player
    /// Send only basic buttons or a full toolbar
    var basic: Bool = false
    /// The view
    func body(content: Content) -> some View {
        if basic {
            /// Return only the player buttons
            content
            HStack {
                prevButton
                playButton
                nextButton
            }
        } else {
            /// Return a full toolbar
            /// - Note: The labels for the toolbar items must be fixed or else Kodio on macOS will crash
            content
                .toolbar(id: "ToolbarButtons") {
                    ToolbarItem(id: "nowPlaying",
                                placement: AppState.shared.system == .macOS ? .automatic : .navigation,
                                showsByDefault: true
                    ) {
                        Label {
                            Text("Now playing")
                        } icon: {
                            playerItemButton
                            /// macOS toolbar is flexible, so make this fixed. Else items might jump
                                .macOS {$0
                                .frame(width: 400, alignment: .leading)
                                .background(Color.secondary.opacity(0.15))
                                .cornerRadius(2)
                                .border(Color.secondary.opacity(0.15), width: 1)
                                }
                                .animation(.default, value: player.item)
                        }
                    }
                    ToolbarItem(id: "spacer",
                                placement: .automatic,
                                showsByDefault: true
                    ) {
                        Spacer()
                    }
                    ToolbarItem(id: "playerButtons",
                                placement: .automatic,
                                showsByDefault: true
                    ) {
                        Label {
                            Text("Player")
                        } icon: {
                            HStack(spacing: 0) {
                                prevButton
                                playButton
                                nextButton
                            }
                            /// Make it all a bit bigger on macOS
                            .macOS {$0
                            .scaleEffect(1.2)
                            .padding(.horizontal, 8)
                            }
                        }
                    }
                    ToolbarItem(id: "shuffleButton",
                                placement: .automatic,
                                showsByDefault: true
                    ) {
                        shuffleButton
                    }
                    ToolbarItem(id: "repeatButton",
                                placement: .automatic,
                                showsByDefault: true
                    ) {
                        repeatButton
                    }
                    ToolbarItem(id: "volumeSlider",
                                placement: .automatic,
                                showsByDefault: true
                    ) {
                        volumeSlider
                    }
                }
        }
    }
}

extension ViewToolbar {
    /// The button to open the queue sheet if any songs
    var playerItemButton: some View {
        Button(
            action: {
                if !player.queueItems.isEmpty {
                    AppState.shared.viewSheet(type: .queue)
                }
            },
            label: {
                HStack(spacing: 0) {
                    ViewPlayerArt(item: player.item, size: 30)
                        .frame(width: 30, height: 30)
                        .cornerRadius(2)
                    playerItem
                }
            }
        )
            .buttonStyle(.plain)
    }
    /// The current item in the player
    var playerItem: some View {
        VStack(alignment: .leading) {
            if !player.item.maintitle.isEmpty {
                Text(player.item.maintitle)
                    .font(.headline)
                    .lineLimit(1)
            } else {
                Text("Kodio")
                    .font(.headline)
                    .lineLimit(1)
            }
            if !player.item.subtitle.isEmpty {
                Text(player.item.subtitle)
                    .font(.subheadline)
            } else if !player.properties.playing {
                Text("Play your own music")
                    .font(.subheadline)
            }
        }
        .padding(.horizontal, 6)
        .id(player.item)
    }
    /// The play/pause button
    var playButton: some View {
        let playing: Bool = player.properties.queueID >= 0 && player.properties.speed == 1 ? true : false
        return Button(
            action: {
                Task.detached(priority: .userInitiated) {
                    await player.playPause()
                }
            },
            label: {
                Image(systemName: playing ? "pause.fill" : "play.fill")
            }
        )
            .disabled(player.queueEmpty)
    }
    /// The next song button
    var prevButton: some View {
        Button(
            action: {
                Task.detached(priority: .userInitiated) {
                    await player.playPrevious()
                }
            },
            label: {
                Image(systemName: "backward.fill")
            }
        )
            .disabled(player.queueFirst)
    }
    /// The previous song button
    var nextButton: some View {
        Button(
            action: {
                Task.detached(priority: .userInitiated) {
                    await player.playNext()
                }
            },
            label: {
                Image(systemName: "forward.fill")
            }
        )
            .disabled(player.queueLast)
    }
    /// The shuffle button
    var shuffleButton: some View {
        let shuffled: Bool = player.properties.shuffled ? true : false
        return Button(
            action: {
                Task.detached(priority: .userInitiated) {
                    await player.toggleShuffle()
                }
            },
            label: {
                Label {
                    Text("Shuffle")
                } icon: {
                    Image(systemName: "shuffle")
                }
                .macOS {
                    $0
                        .foregroundColor(shuffled ? .accentColor : .primary)
                }
                .iOS {
                    $0
                        .padding(2)
                        .background(RoundedRectangle(cornerRadius: 4)
                                        .fill(shuffled ? Color.accentColor : Color.clear))
                        .foregroundColor(shuffled ? .white : .primary)
                }
            }
        )
    }
    /// The repeat button
    var repeatButton: some View {
        let repeating: Bool = player.properties.repeating == "off" ? false : true
        return Button(
            action: {
                Task.detached(priority: .userInitiated) {
                    await player.toggleRepeat()
                }
            },
            label: {
                Label {
                    Text("Repeat")
                } icon: {
                    Image(systemName: player.properties.repeatingIcon)
                }
                .macOS {$0
                .foregroundColor(repeating ? .accentColor : .primary)
                }
                .iOS {$0
                .padding(2)
                .background(RoundedRectangle(cornerRadius: 4)
                                .fill(repeating ? Color.accentColor : Color.clear))
                .foregroundColor(repeating ? .white : .primary)
                }
            }
        )
    }
    /// The volume slider
    var volumeSlider: some View {
        Label {
            Text("Volume")
        } icon: {
            HStack {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                /// - Note: Using 'onEditingChanged' because that will only be trickered when using the slider
                ///         and not when programmaticly changing its value after a notification.
                Slider(value: $player.volume, in: 0...100,
                       onEditingChanged: { _ in
                    logger("Volume changed: \(player.volume)")
                    Task.detached(priority: .userInitiated) {
                        await player.setVolume(volume: player.volume)
                    }
                })
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
            }
        }
        .frame(width: 160)
    }
}
