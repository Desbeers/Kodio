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
            .toolbar(id: "queue") {
                ToolbarItem(id: "queueButton", placement: .navigation, showsByDefault: true) {
                    Label {
                        Text("Queue")
                    } icon: {
                        ViewPlayerQueueButton(artSize: 30)
                    }
                }
            }
            .toolbar(id: "toolbar") {
                ToolbarItem(id: "player", placement: .automatic, showsByDefault: true) {
                    Label {
                        Text("Player")
                    } icon: {
                        ViewPlayerButtons()
                    }
                }
                ToolbarItem(id: "options", placement: .automatic, showsByDefault: true) {
                    Label {
                        Text("Options")
                    } icon: {
                        ViewPlayerOptions()
                    }
                }
                ToolbarItem(id: "volume", placement: .automatic, showsByDefault: true) {
                    Label {
                        Text("Volume")
                    } icon: {
                        ViewPlayerVolume()
                            .frame(width: 160)
                    }
                }
            }
            .disabled(appState.state != .loadedLibrary)
    }
}
