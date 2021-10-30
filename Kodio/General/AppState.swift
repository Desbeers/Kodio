//
//  AppState.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The state of Kodio
class AppState: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this AppState class
    static let shared = AppState()
    /// Bool to show or hide a SwiftUI sheet
    @Published var showSheet: Bool = false
    /// Define what kind of sheet to show
    @Published var activeSheet: SheetTypes = .queue
    /// The struct for a SwiftUI Alert item
    @Published var alertItem: AlertItem?
    /// The loading state of the application
    @Published var loadingState: LoadingState = .none {
        didSet {
            loadingActions(state: loadingState)
        }
    }
    /// To Mac or nor to Mac?
    /// - Note:The iOS app thingy will override if not mac...
    var userInterface: UserInterface = .macOS
    
    // MARK: Init
    
    /// Do a private init to make sure we have only one instance
    private init() {}
}

extension AppState {
    
    // MARK: Sheets
    
    /// The different kind of sheets
    enum SheetTypes {
        /// Show the playing queue view
        case queue
        /// Show the settings view
        case settings
        /// Show the about view
        case about
        /// Show the help view
        case help
    }
}

extension AppState {
    
    // MARK: State of library loading
    
    /// Actions when the loading state of Kodio is changing
    /// - Parameter state: the current ``LoadingState``
    func loadingActions(state: LoadingState) {
        switch state {
        case .connected:
            Library.shared.getLibrary()
        case .loaded:
            /// Get the properties of the player
            Task {
                await Player.shared.getProperties()
                /// Get the current item loaded into the player
                await Player.shared.getItem()
                /// Get the song queue
                await Queue.shared.getItems()
            }
        case .sleeping:
            logger("Kodio sleeping (\(userInterface))")
            KodiClient.shared.disconnectWebSocket()
        case .wakeup:
            logger("Kodio awake (\(userInterface))")
            KodiClient.shared.connectWebSocket()
        default:
            break
        }
    }
    
    /// The state of the library loading
    enum LoadingState {
        /// Not connected and no host
        case none
        /// Connected to the host
        case connected
        /// Loading the library
        case loading
        /// Library loaded
        case loaded
        /// App is sleeping
        case sleeping
        /// App wakeup
        case wakeup
        /// An error when loading the library or a lost of connection
        case failure
        /// Not configured
        case noConfig
    }
}

extension AppState {
    
    // MARK: Alerts
    
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
                    AppState.shared.alertItem = nil
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
            Text("\(AppState.shared.userInterface == .macOS ? "Open preferences" : "Add a host")"),
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
                Library.shared.getLibrary(reload: true)
            }
        )
        return alert
    }

}

extension AppState {
    
    // MARK: User interface
    
    /// Is this a mac, iPad or iPhone application?
    enum UserInterface: String {
        /// macOS
        case macOS
        /// iPadOS
        case iPad
        /// iOS
        case iPhone
    }
    
}
