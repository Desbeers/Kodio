//
//  MenuBarExtraView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the Menubar Extra
struct MenuBarExtraView: View {
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector

    /// The KodiPlayer model
    @StateObject var player: KodiPlayer = .shared

    var body: some View {
        VStack {
            ToolbarView.NowPlaying()
                .frame(height: 80)
            HStack {
                MediaButtons.PlayPrevious()
                MediaButtons.PlayPause()
                MediaButtons.PlayNext()
            }
            .padding()
            MediaButtons.VolumeSlider()
        }
        .labelStyle(.iconOnly)
        .padding(.bottom)
        .environmentObject(player)
    }
}
