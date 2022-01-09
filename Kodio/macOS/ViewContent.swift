//
//  ViewContent.swift
//  Kodio (macOS)
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// The main view for Kodio
struct ViewContent: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        NavigationView {
            ViewSidebar()
                .searchbar()
            ViewLibrary()
                .toolbarButtons()
        }
        .sheet(isPresented: $appState.showSheet) {
            ViewSheet()
        }
        .alert(item: $appState.alert) { alertItem in
            return alertContent(content: alertItem)
        }
    }
}
