//
//  ViewSettings.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View the Kodio settings
struct ViewSettings: View {
    /// The view
    var body: some View {
        #if os (macOS)
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
        #endif
        #if os (iOS)
        ViewEditHosts()
        #endif
    }
}
