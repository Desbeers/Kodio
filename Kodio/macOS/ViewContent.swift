//
//  ViewContent.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View content (macOS)

/// The main view for the whole content
struct ViewContent: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        NavigationView {
            ViewSidebar()
            ViewLibrary()
        }
        .toolbar()
        .searchbar()
        .sheet(isPresented: $appState.showSheet) {
            ViewSheet()
        }
        .alert(item: $appState.alertItem) { alertItem in
            return alertContent(content: alertItem)
        }
    }
}
