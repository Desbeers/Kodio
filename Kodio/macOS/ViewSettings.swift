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
        }
        .frame(width: 700, height: 400)
    }
}
