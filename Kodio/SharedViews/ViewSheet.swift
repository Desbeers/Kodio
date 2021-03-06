//
//  ViewSheet.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// A sheet view
struct ViewSheet: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        ZStack(alignment: .topLeading) {
            /// Show the correct 'sheet'
            switch appState.activeSheet {
            case .queue:
                ViewQueue()
            case .editHosts:
                ViewEditHosts()
            case .editRadio:
                ViewEditRadio()
            case .about:
                ViewAbout()
            case .help:
                ViewHelp()
            case .importExport:
                ViewImportExport()
            }
#if os(macOS)
            Button {
                appState.showSheet = false
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
