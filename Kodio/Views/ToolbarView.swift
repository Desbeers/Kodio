//
//  ToolbarView.swift
//  Kodio
//
//  Created by Nick Berendsen on 16/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Toolbar View Modifier
struct ToolbarView: ViewModifier {
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The toolbar
    func body(content: Content) -> some View {
        content
            .toolbar(id: "Toolbar") {
                ToolbarItem(
                    id: "previousButton",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    MediaButtons.PlayPrevious()
                }
                ToolbarItem(
                    id: "playPauseButton",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    MediaButtons.PlayPause()
                }
                ToolbarItem(
                    id: "nextButton",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    MediaButtons.PlayNext()
                }
                ToolbarItem(
                    id: "nowPlaying",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    Label {
                        Text("Now playing")
                    } icon: {
                        NowPlaying()
                            .frame(maxHeight: 50)
                    }
                }
                ToolbarItem(
                    id: "shuffleButton",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    MediaButtons.SetShuffle()
                }
                ToolbarItem(
                    id: "repeatButton",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    MediaButtons.SetRepeat()
                }
                ToolbarItem(
                    id: "partyButton",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    SetPartyMode()
                }
                ToolbarItem(
                    id: "volumeSlider",
                    placement: .automatic,
                    showsByDefault: true
                ) {
                    MediaButtons.VolumeSlider()
                }
            }
            .toolbarRole(.editor)
    }
}

extension ToolbarView {

    /// The 'Now Playing' View
    struct NowPlaying: View {
        /// The KodiPlayer model
        @EnvironmentObject var player: KodiPlayer
        /// The body of the `View`
        var body: some View {
            HStack(spacing: 0) {
                if let nowPlaying = player.currentItem {
                    KodiArt.Poster(item: nowPlaying)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                } else {
                    Image("Record")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxHeight: .infinity)
                }
                ZStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text(player.currentItem?.title ?? "Kodio")
                            .font(.headline)
                        Text(player.currentItem?.subtitle ?? "Nothing is playing")
                            .font(.subheadline)
                    }
                    .padding(.leading, 8)
                    NowPlayingProgressView()
                }
            }
            .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.15))
            .border(Color.secondary.opacity(0.15), width: 1)
        }
    }
}

// MARK: Progress of the playing item

extension ToolbarView {

    /// SwiftUI `View` for the progess of the current item in the player
    struct NowPlayingProgressView: View {
        /// The `KodiPlayer` model
        @EnvironmentObject var player: KodiPlayer
        /// The current seconds
        @State var currentSeconds: Double = 0
        /// The total seconds
        @State var totalSeconds: Double = 0
        /// The time the item started to play
        @State var startTime: Date = .now
        /// The body of the `View`
        var body: some View {
            if player.currentItem != nil && player.currentItem?.media != .stream {
                TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                    ProgressTimelineView(percentage: percentageValue(for: timeline.date))
                }
                .task(id: player.properties.time) {
                    setTime()
                }
            }
        }
        /// Set the time
        private func setTime() {
            currentSeconds = Double(player.properties.time.total)
            totalSeconds = Double(player.properties.timeTotal.total)
            startTime = Date.now
        }
        /// Calculate percentage played
        private func percentageValue(for date: Date) -> Double {
            let interval = startTime.distance(to: date)
            let percentage = (currentSeconds + interval) / totalSeconds
            /// Don't ever return a value greater than 1
            return percentage < 1 ? percentage : 1
            }
    }

    /// SwiftUI `View` for the progress
    struct ProgressTimelineView: View {
        /// Played percentage
        let percentage: Double
        /// The body of the `View`
        var body: some View {
            ProgressView(value: percentage)
                .progressViewStyle(NowPlayingProgressViewStyle())
                .animation(.default, value: percentage)
        }
    }

    /// The SwiftUI `ProgressViewStyle`
    struct NowPlayingProgressViewStyle: ProgressViewStyle {
        func makeBody(configuration: Configuration) -> some View {
            GeometryReader { geometry in
                Rectangle()
                    .frame(width: Double(configuration.fractionCompleted ?? 0) * geometry.size.width)
                    .foregroundColor(.accentColor)
            }
            .opacity(0.1)
        }
    }
}

extension ToolbarView {

    /// Partymode button (forced to audio)
    ///
    /// - Note: This will set 'Party Mode' for audio, I don't see a use of videos for this
    struct SetPartyMode: View {
        /// The `KodiPlayer` model
        @EnvironmentObject var player: KodiPlayer
        /// The body of the `View`
        var body: some View {
            Button(action: {
                Task {
                    if player.properties.partymode {
                        Player.setPartyMode(playerID: .audio)
                    } else {
                        KodioSettings.setPlayerSettings(media: .partymode)
                        Player.open(partyMode: .music)
                    }
                }
            }, label: {
                Label(title: {
                    Text("Party Mode")
                }, icon: {
                    Image(systemName: "wand.and.stars.inverse")
                        .padding(2)
                        .foregroundColor(player.properties.partymode ? .white : .none)
                })
                .background(
                    player.properties.partymode ? Color.red : Color.clear, in: RoundedRectangle(cornerRadius: 4)
                )
            })
            .help("Music party mode")
        }
    }
}
