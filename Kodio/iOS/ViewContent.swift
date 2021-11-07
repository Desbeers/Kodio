//
//  ViewContent.swift
//  Kodio (iOS)
//
//  © 2021 Nick Berendsen
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
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            ViewHostsMenu()
                            Divider()
                            Button("Edit hosts") {
                                Task {
                                    appState.viewSheet(type: .settings)
                                }
                            }
                            Button(
                                action: {
                                    Task {
                                        appState.viewSheet(type: .help)
                                    }
                                },
                                label: {
                                    Text("Help")
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
