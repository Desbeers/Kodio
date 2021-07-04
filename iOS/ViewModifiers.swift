///
/// ViewModifiers.swift
/// Kodio (iOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ToolbarModifier: ViewModifier {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    /// Search
    @StateObject var searchObserver = SearchFieldObserver.shared
    /// The modifier
    func body(content: Content) -> some View {
        Divider()
        content
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    HStack(spacing: 10) {
                        ViewPlayerItem()
                        Spacer()
                        ViewPlayerButtons()
                        Spacer()
                        ViewPlayerOptions()
                        Spacer()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack(spacing: 10) {
                        Image(systemName: "gear")
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
                        ViewPlayerVolume()
                            .frame(width: 160)
                    }
                }
            }
    }
}

struct DetailsModifier: ViewModifier {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    func body(content: Content) -> some View {
        content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
    }
}
