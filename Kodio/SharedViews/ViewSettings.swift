//
//  ViewSettings.swift
//  Kodio (shared)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewSettings: View {
    /// The Library model
    @EnvironmentObject var library: Library
    var body: some View {
        #if os (macOS)
        TabView {
            ViewHostsEdit()
            .tabItem {
                Label("Hosts", systemImage: "list.dash")
            }
        }
        #endif
        #if os (iOS)
        ViewHostsEdit()
        #endif
    }
}
