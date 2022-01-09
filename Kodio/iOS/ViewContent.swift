//
//  ViewContent.swift
//  Kodio (iOS)
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// The main view for Kodio
struct ViewContent: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        NavigationView {
            ViewSidebar()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: iOStoolbar)
            ViewLibrary()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        }
        .searchbar()
        .sheet(isPresented: $appState.showSheet) {
            ViewSheet()
        }
        .alert(item: $appState.alert) { alertItem in
            return alertContent(content: alertItem)
        }
    }
}

extension ViewContent {
    
    /// The iOS toolbar for the sidebar
    @ToolbarContentBuilder func iOStoolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                ViewHostSelector()
                Divider()
                if appState.state == .loadedLibrary {
                    Button("Scan library on '\(appState.selectedHost.description)'") {
                        KodiHost.shared.scanAudioLibrary()
                    }
                    Divider()
                }
                Button("Edit Kodi Hosts") {
                    Task {
                        appState.viewSheet(type: .editHosts)
                    }
                }
                Button("Edit Radio Stations") {
                    Task {
                        appState.viewSheet(type: .editRadio)
                    }
                }
                Button("Import & Export") {
                    Task {
                        appState.viewSheet(type: .importExport)
                    }
                }
                Button(
                    action: {
                        Task {
                            appState.viewSheet(type: .help)
                        }
                    },
                    label: {
                        Text("Kodio Help")
                    }
                )
                Button(
                    action: {
                        Task {
                            appState.viewSheet(type: .about)
                        }
                    },
                    label: {
                        Text("About Kodio")
                    }
                )
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}
