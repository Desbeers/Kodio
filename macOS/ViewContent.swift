///
/// ViewContent.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ViewContent: View {
//    /// The object that has it all
//    @EnvironmentObject var kodi: KodiClient
    /// State of the application
    @EnvironmentObject var appState: AppState
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    /// State of the seachfield in the toolbar
    @State private var search = ""
    /// The view
    var body: some View {
        NavigationView {
            if !KodiClient.shared.library.all {
                EmptyView()
                    .frame(minWidth: 250, idealWidth: 250, maxWidth: 400, maxHeight: .infinity)
                VStack {
                    Spacer()
                    ViewKodiRotatingIcon()
                    Spacer()
                    ViewKodiLoading()
                    Spacer()
                    if showLog {
                        ViewLog()
                    }
                }
                /// BUG: Empty toolbar to fill the space;
                /// else the toolbar will disappear when starting in fullscreen
                .toolbar {
                    ToolbarItem {
                        Spacer()
                    }
                }
            } else {
                ViewSidebar()
                    .frame(minWidth: 250, idealWidth: 250, maxWidth: 400, maxHeight: .infinity)
//                ViewAlbums()
//                    .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity, maxHeight: .infinity)
                ViewDetails()
//                    .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $appState.showSheet, content: sheetContent)
        .alert(item: $appState.alertItem) { alertItem in
            return alertContent(alertItem)
        }
    }
}
