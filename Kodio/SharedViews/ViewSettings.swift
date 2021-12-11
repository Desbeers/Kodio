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
                Label("Preferences", systemImage: "gear")
            }
        }
        .frame(width: 700, height: 350)
        #endif
        #if os (iOS)
        ViewEditHosts()
        #endif
    }
}
