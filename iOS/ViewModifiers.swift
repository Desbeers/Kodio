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
        HStack {
        SearchField(search: $searchObserver.searchText)
            .frame(minWidth: 100, idealWidth: 150, maxWidth: 200)
            ViewPlayerVolume()
                .frame(width: 160)
        }
        content
            .toolbar {
                ToolbarItemGroup(placement: .principal) {
                    HStack(spacing: 10) {
                        ViewPlayerButtons()
                        Spacer()
                        ViewPlayerOptions()
                        Spacer()
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack(spacing: 10) {
                        Spacer()
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
                    }
                }
            }
    }
}

struct AlbumsModifier: ViewModifier {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    func body(content: Content) -> some View {
        content
            .navigationTitle("Kodio")
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailsModifier: ViewModifier {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    func body(content: Content) -> some View {
        ViewPlayerItem()
        content
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
    }
}
