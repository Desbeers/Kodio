//
//  ViewModifierToolbar.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewModifierToolbar: ViewModifier {
    /// The Player model
    @EnvironmentObject var player: Player
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 0) {
                        ViewPlayerQueueButton(artSize: 30)
                        VStack(alignment: .leading) {
                            Text(player.title)
                                .font(.subheadline.weight(.bold))
                            Text(player.artist)
                                .font(.caption)
                        }
                        .padding(.leading, 8)
                        Spacer()
                    }
                }
                ToolbarItemGroup {
                    HStack(spacing: 20) {
                        ViewPlayerButtons()
                        Spacer()
                        ViewPlayerOptions()
                        Spacer()
                        ViewPlayerVolume()
                            .frame(width: 160)
                        Spacer()
                    }
                    .scaleEffect(0.9)
                }
            }
            .disabled(appState.state != .loadedLibrary)
    }
}
