//
//  AppStateAlerts.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

extension AppState {
    
    // MARK: Alerts for Kodio

    /// View a SwiftUI alert
    /// - Parameter type: An ``AlertItem``.
    @MainActor func viewAlert(type: AlertItems) {
        alert = type.show()
    }
    
    /// The Alert items Kodio can show
    enum AlertItems: String {
        /// The library is outdated
        case outdatedLibrary
        /// The host is not available
        case hostNotAvailable
        /// The are no hosts defined
        case noHosts
        /// Rescan the library
        case scanLibrary
        /// Show the alert
        func show() -> AlertItem {
            switch self {
            case .outdatedLibrary:
                return AlertItem(
                    title: Text("Reload Library"),
                    message: Text("Your library is not in sync with \(AppState.shared.selectedHost.description)."),
                    button: .default(
                        Text("Reload"),
                        action: {
                            Library.shared.getLibrary(reload: true)
                        }
                    )
                )
            case .hostNotAvailable:
                return AlertItem(
                    title: Text("\(AppState.shared.selectedHost.description) is not available"),
                    message: Text("Kodi is not available or the connection is lost."),
                    button: .default(
                        Text("Retry"),
                        action: {
                            KodiClient.shared.connectWebSocket()
                        }
                    )
                )
            case .noHosts:
                return AlertItem(
                    title: Text("Welcome to Kodio!"),
                    message: Text("Please add a Kodi host."),
                    dismiss: .default(
                        Text("\(AppState.shared.system == .macOS ? "Open preferences" : "Add a host")"),
                        action: {
#if os(macOS)
                            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
#endif
#if os(iOS)
                            Task {
                                await AppState.shared.viewSheet(type: .editHosts)
                            }
#endif
                        }
                    )
                )
            case .scanLibrary:
                return AlertItem(
                    title: Text("Reload Library"),
                    message: Text("Are you sure you want to reload the library on  \(AppState.shared.selectedHost.description)?\n\nThis might take some time..."),
                    button: .default(
                        Text("Reload"),
                        action: {
                            Library.shared.getLibrary(reload: true)
                        }
                    )
                )
            }
        }
    }
    
    /// A struct for building a SwiftUI Alert
    struct AlertItem: Identifiable {
        /// Make it indentifiable
        var id = UUID()
        /// The title of the alert
        var title = Text("")
        /// The message to show in the alert
        var message: Text?
        /// The buttons to show with the alert
        var button: Alert.Button?
        /// The buttons to show to dismiss the alert
        var dismiss: Alert.Button?
    }
}
