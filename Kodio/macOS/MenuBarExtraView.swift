//
//  MenuBarExtraView.swift
//  Kodio
//
//  Created by Nick Berendsen on 16/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Menubar Extra View
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
