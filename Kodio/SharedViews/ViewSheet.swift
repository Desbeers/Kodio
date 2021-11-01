//
//  ViewSheet.swift
//  Kodio (shared)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// A sheet view
struct ViewSheet: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        ZStack {
            /// Show the correct 'sheet'
            switch appState.activeSheet {
            case .queue:
                ViewQueue()
            case .settings:
                ViewSettings()
            case .about:
                ViewAbout()
            case .help:
                ViewHelp()
            }
#if os(macOS)
            VStack {
                HStack {
                    Button {
                        appState.showSheet = false
                    } label: {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.accentColor)
                            .font(.title)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding()
                    Spacer()
                }
                Spacer()
            }
#endif
        }
        /// Make this 'sheet' closable with a swipe. Normal on iOS but now also works on macOS
        .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onEnded { _ in
            appState.showSheet = false
        })
    }
}
