//
//  ViewContent.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View content (iOS)

struct ViewContent: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The Combine thingy so it is not searching after every typed letter
    @StateObject var searchObserver: SearchObserver = .shared
    var body: some View {
        NavigationView {
            ViewSidebar()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ViewHostsMenu()
                            Divider()
                            Button("Edit hosts") {
                                withAnimation {
                                    appState.activeSheet = .settings
                                    appState.showSheet = true
                                }
                            }
                            Button(
                                action: {
                                    appState.activeSheet = .help
                                    appState.showSheet = true
                                },
                                label: {
                                    Text("Help")
                                }
                            )
                            Button(
                                action: {
                                    appState.activeSheet = .about
                                    appState.showSheet = true
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
            ViewLibrary()
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
        }
        .searchbar()
        .sheet(isPresented: $appState.showSheet) {
            ViewSheet()
        }
        .alert(item: $appState.alertItem) { alertItem in
            return alertContent(content: alertItem)
        }
    }
}