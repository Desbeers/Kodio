//
//  ViewSettings.swift
//  Kodio (macOS)
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// View the Kodio settings
struct ViewSettings: View {
    /// The view
    var body: some View {
        TabView {
            ViewEditHosts()
            .tabItem {
                Label("Kodi Hosts", systemImage: "gear")
            }
            ViewEditRadio()
            .tabItem {
                Label("Radio Stations", systemImage: "antenna.radiowaves.left.and.right")
            }
            ViewSyncRatings()
            .tabItem {
                Label("Sync Ratings", systemImage: "arrow.triangle.2.circlepath")
            }
            ViewImportExport()
            .tabItem {
                Label("Import & Export", systemImage: "square.and.arrow.down")
            }
        }
        .frame(width: 700, height: 400)
    }
}
