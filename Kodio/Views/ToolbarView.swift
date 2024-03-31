//
//  ToolbarView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `ViewModifier` for the toolbar
struct ToolbarView: ViewModifier {
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
#if os(visionOS)
    /// Placement of the toolbar
    let placement: ToolbarItemPlacement = .bottomOrnament
#else
    /// Placement of the toolbar
    let placement: ToolbarItemPlacement = .automatic
#endif

    /// The toolbar
    func body(content: Content) -> some View {
        content
            .toolbar(id: "Toolbar") {
                ToolbarItem(
                    id: "previousButton",
                    placement: placement,
                    showsByDefault: true
                ) {
                    MediaButtons.PlayPrevious()
                }
                ToolbarItem(
                    id: "playPauseButton",
                    placement: placement,
                    showsByDefault: true
                ) {
                    MediaButtons.PlayPause()
                }
                ToolbarItem(
                    id: "nextButton",
                    placement: placement,
                    showsByDefault: true
                ) {
                    MediaButtons.PlayNext()
                }
                ToolbarItem(
                    id: "nowPlaying",
                    placement: placement,
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
                    placement: placement,
                    showsByDefault: true
                ) {
                    MediaButtons.SetShuffle()
                }
                ToolbarItem(
                    id: "repeatButton",
                    placement: placement,
                    showsByDefault: true
                ) {
                    MediaButtons.SetRepeat()
                }
                ToolbarItem(
                    id: "partyButton",
                    placement: placement,
                    showsByDefault: true
                ) {
                    SetPartyMode()
                }
                ToolbarItem(
                    id: "volumeMute",
                    placement: placement,
                    showsByDefault: true
                ) {
                    MediaButtons.VolumeMute()
                }
                ToolbarItem(
                    id: "volumeSlider",
                    placement: placement,
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
        /// The KodiConnector model
        @Environment(KodiConnector.self) private var kodi
        /// The body of the `View`
        var body: some View {
            HStack(spacing: 0) {
                if let nowPlaying = kodi.player.currentItem {
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
                        Text(kodi.player.currentItem?.title ?? "Kodio")
                            .font(.headline)
                        Text(kodi.player.currentItem?.subtitle ?? "Nothing is playing")
                            .font(.subheadline)
                    }
                    .padding(.leading, 8)
                    NowPlayingProgressView()
                }
            }
            .frame(minWidth: 300, maxWidth: 300, maxHeight: .infinity, alignment: .leading)
            .background(Color.secondary.opacity(0.15))
            .border(Color.secondary.opacity(0.15), width: 1)
#if os(visionOS)
            .ornament(attachmentAnchor: .scene(.trailing)) {
                if let nowPlaying = kodi.player.currentItem {
                    KodiArt.Poster(item: nowPlaying)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 100)
                        .clipShape(.rect(cornerRadius: 10))
                        .frame(depth: 100)
                }
            }
#endif
        }
    }
}

// MARK: Progress of the playing item

extension ToolbarView {

    /// SwiftUI `View` for the progess of the current item in the player
    struct NowPlayingProgressView: View {
        /// The KodiConnector model
        @Environment(KodiConnector.self) private var kodi
        /// The current seconds
        @State private var currentSeconds: Double = 0
        /// The total seconds
        @State private var totalSeconds: Double = 0
        /// The time the item started to play
        @State private var startTime: Date = .now
        /// The body of the `View`
        var body: some View {
            if kodi.player.currentItem != nil &&
                kodi.player.currentItem?.media != .stream &&
                kodi.player.properties.speed != 0 {
                TimelineView(.periodic(from: .now, by: 1.0)) { timeline in
                    ProgressTimelineView(percentage: percentageValue(for: timeline.date))
                }
                .task(id: kodi.player.properties.time) {
                    setTime()
                }
            }
        }
        /// Set the time
        private func setTime() {
            currentSeconds = Double(kodi.player.properties.time.total)
            totalSeconds = Double(kodi.player.properties.timeTotal.total)
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
    /// - Note: animating this View cost a lot of CPU
    struct ProgressTimelineView: View {
        /// Played percentage
        let percentage: Double
        /// The body of the `View`
        var body: some View {
            ProgressView(value: percentage)
                .progressViewStyle(NowPlayingProgressViewStyle())
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
            .opacity(0.2)
        }
    }
}

extension ToolbarView {

    /// Partymode button (forced to audio)
    ///
    /// - Note: This will set 'Party Mode' for audio, I don't see a use of videos for this
    struct SetPartyMode: View {
        /// The AppState model
        @Environment(AppState.self) private var appState
        /// The KodiConnector model
        @Environment(KodiConnector.self) private var kodi
        /// The body of the `View`
        var body: some View {
            Button(action: {
                Task {
                    if kodi.player.properties.partymode {
                        Player.setPartyMode(host: kodi.host, playerID: .audio)
                    } else {
                        appState.setPlayerSettings(host: kodi.host, media: .partymode)
                        Player.open(host: kodi.host, partyMode: .music)
                    }
                }
            }, label: {
                Label(title: {
                    Text("Party Mode")
                }, icon: {
                    Image(systemName: "wand.and.stars.inverse")
                })
            })
            .mediaButtonStyle(background: kodi.player.properties.partymode, color: .red, help: "Music party mode")
        }
    }
}
