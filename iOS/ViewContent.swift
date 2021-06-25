///
/// ViewContent.swift
/// Kodio (iOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

/// Three colums navigation sucks on iOS.
/// We will fake the sidebar color

struct ViewContent: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    
    var body: some View {
        Group {
            
            if !kodi.library.all {
                VStack {
                    Spacer()
                    ViewKodiRotatingIcon()
                        .frame(maxWidth: 500, maxHeight: 500)
                    Spacer()
                    ViewKodiLoading()
                        .frame(height: 100)
                    Spacer()
                    Spacer()
                    if showLog {
                        ViewLog()
                    }
                }
            } else {
                if kodi.userInterface == .iPad {
                    ViewiPad()
                } else {
                    ViewiPhone()
                    //ViewiPad()
                }
            }
        }
        .sheet(isPresented: $appState.showSheet, content: sheetContent)
        .alert(item: $appState.alertItem) { alertItem in
            return alertContent(alertItem)
        }
    }
}
