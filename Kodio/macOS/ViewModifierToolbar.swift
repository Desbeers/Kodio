//
//  ViewModifierToolbar.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The toolbar
struct ViewModifierToolbar: ViewModifier {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    ViewPlayerQueueButton(artSize: 30)
                }
                ToolbarItemGroup {
                    Spacer()
                    ViewPlayerButtons()
                    Spacer()
                    ViewPlayerOptions()
                    Spacer()
                    ViewPlayerVolume()
                        .frame(width: 160)
                }
            }
            .disabled(appState.state != .loadedLibrary)
    }
}
