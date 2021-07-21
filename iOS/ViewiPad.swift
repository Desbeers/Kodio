///
/// ViewiPad.swift
/// Kodio (iOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ViewiPad: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    var body: some View {
        NavigationView {
            ViewSidebar()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            ViewDetails()
        }
    }
}
