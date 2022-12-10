//
//  SheetView.swift
//  Kodio
//
//  Created by Nick Berendsen on 15/08/2022.
//

import SwiftUI

/// The View for a Sheet
struct SheetView: View {
    /// The SceneState model
    @EnvironmentObject var scene: SceneState
    /// The body of the `View`
    var body: some View {
        ZStack(alignment: .topLeading) {
            /// Show the correct 'sheet'
            switch scene.activeSheet {
            case .settings:
                SettingsView()
            case .about:
                AboutView()
            case .help:
                HelpView()
            }
#if os(macOS)
            Button {
                scene.showSheet = false
            } label: {
                Image(systemName: "xmark.circle")
                    .foregroundColor(.accentColor)
                    .font(.title)
            }
            /// Close `Sheets` when pressing *return* on the keyboard
            .keyboardShortcut(.defaultAction)
            .buttonStyle(.plain)
            .padding()
#endif
        }
    }
}
