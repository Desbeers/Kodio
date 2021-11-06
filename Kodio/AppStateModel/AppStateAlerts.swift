//
//  AppStateAlerts.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

extension AppState {
    
    // MARK: Alerts for Kodio
    
    /// A struct for building a SwiftUI Alert
    struct AlertItem: Identifiable {
        /// Generated ID
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
    
    /// The alert that pops-up when the library is outdated
    var alertOutdatedLibrary: AlertItem {
        var alert = AlertItem()
        alert.title = Text("Reload Library")
        alert.message = Text("Your library is not in sync with \(KodiClient.shared.selectedHost.description).")
        alert.button = .default(
            Text("Reload"),
            action: {
                /// Stop nagging after one time
                DispatchQueue.main.async {
                    AppState.shared.alert = nil
                }
                Library.shared.getLibrary(reload: true)
            }
        )
        return alert
    }

    /// The alert that pops-up when the host is not available
    var alertNotAvailable: AlertItem {
        var alert = AlertItem()
        alert.title = Text("\(KodiClient.shared.selectedHost.description) is not available")
        alert.message = Text("Kodi is not available or the connection is lost.")
        alert.button = .default(
            Text("Retry"),
            action: {
                KodiClient.shared.connectWebSocket()
            }
        )
        return alert
    }

    /// The alert that pops-up when there are no hosts
    var alertNoHosts: AlertItem {
        var alert = AlertItem()
        alert.title = Text("Welcome to Kodio!")
        alert.message = Text("Please add a Kodi host.")
        alert.dismiss = .default(
            Text("\(AppState.shared.system == .macOS ? "Open preferences" : "Add a host")"),
            action: {
#if os(macOS)
                NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
#endif
#if os(iOS)
                self.activeSheet = .settings
                self.showSheet = true
#endif
            }
        )
        return alert
    }
    
    /// The alert that pops-up when reload is requested
    var alertScanLibrary: AlertItem {
        var alert = AlertItem()
        alert.title = Text("Reload Library")
        alert.message = Text("Are you sure you want to reload the library on  \(KodiClient.shared.selectedHost.description)?\n\nThis might take some time...")
        alert.button = .default(
            Text("Reload"),
            action: {
                Library.shared.resetLibrary()
                Library.shared.getLibrary(reload: true)
            }
        )
        return alert
    }

}
