//
//  ViewiPad.swift
//  Kodio (iOS)
//
//  Created by Nick Berendsen on 04/06/2021.
//

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
            //ViewAlbums()
            ViewDetails()
        }
    }
}
