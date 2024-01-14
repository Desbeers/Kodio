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
    @Environment(KodiConnector.self)
    private var kodi
    /// The body of the `View`
    var body: some View {
        VStack {
            ToolbarView.NowPlaying()
                .frame(height: 80)
            HStack {
                MediaButtons.PlayPrevious()
                MediaButtons.PlayPause()
                MediaButtons.PlayNext()
            }
            .padding(.horizontal)
            HStack {
                MediaButtons.VolumeSlider()
                MediaButtons.VolumeMute()
                    .frame(height: 30)
            }
                .padding(.horizontal)
        }
        .labelStyle(.iconOnly)
        .padding(.bottom)
        .environment(kodi)
    }
}
