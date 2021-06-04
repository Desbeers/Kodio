///
/// FooterView.swift
/// Kodio (iOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct FooterView: View {
    @EnvironmentObject var kodi: KodiClient
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                Menu(kodi.selectedHost.description) {
                    ViewKodiHostsMenu()
                    Button(showLog ? "Hide Console Messages" : "Show Console Messages") {
                        withAnimation {
                            showLog.toggle()
                        }
                    }
                    Button("Scan Library") {
                        kodi.scanAudioLibrary()
                    }
                    .disabled(kodi.libraryIsScanning)
                }
                Spacer()
            }
            if kodi.library.all {
                HStack {
                    ViewPlayerButtons()
                }
                HStack {
                    Spacer()
                    ViewPlayerOptions()
                }
            }
        }
        .buttonStyle(ViewPlayerStyleButton())
        .padding()
        .border(Color.secondary.opacity(0.3))
        .background(Color("iOSplayerBackground").opacity(0.95))
    }
}
