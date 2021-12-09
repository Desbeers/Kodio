//
//  AppState.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// The AppState model
///
/// This class takes care of:
/// - The state of Kodio
/// - Connect to a selected host
/// - Checks what system is running Kodio
/// - Showing sheets
/// - Showing alerts
final class AppState: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this AppState class
    static let shared = AppState()
    /// The shared KodiClient class
    let kodiClient = KodiClient.shared
    /// Bool to show or hide a SwiftUI sheet
    @Published var showSheet: Bool = false
    /// Define what kind of sheet to show
    var activeSheet: Sheets = .queue
    /// The struct for a SwiftUI Alert item
    @Published var alert: AlertItem?
    /// Bool if we are scanning the libraray on a host
    @Published var scanningLibrary = false
    /// The state of Kodio
    @Published var state: State = .none
    /// The sidebar items
    @Published var sidebarItems: [Library.LibraryListItem] = []
    /// The selection in the sidebar
    @Published var sidebarSelection: Library.LibraryListItem? {
        didSet {
            Task { @MainActor in
                /// An item is manual selected in the sidebar
                if sidebarSelection != Library.shared.libraryLists.selected, sidebarSelection != nil {
                    await Library.shared.selectLibraryList(libraryList: self.sidebarSelection!)
                }
                /// iOS makes this sometimes nill for no good reason
                if sidebarSelection == nil, AppState.shared.system  != .iPhone {
                    sidebarSelection = Library.shared.libraryLists.selected
                }
            }
        }
    }
    /// Check if Kodio is running on a Mac or on an iOS device
    /// - Note:The iOS app thingy will override this `var` if Kodio is not running on a Mac
    var system: System = .macOS
    /// An array with all Kodi hosts
    @Published var hosts: [HostItem]
    /// A struct with selected host information
    /// - Note: This will make the connection when set or changed
    @Published var selectedHost = HostItem() {
        didSet {
            Task {
                await kodiClient.connectToHost(host: selectedHost)
            }
        }
    }
    /// ID of this Kodio instance; used to send  notifications
    var kodioID = UUID().uuidString
    
    // MARK: Init
    
    /// Do a private init to make sure we have only one instance of the AppState class
    private init() {
        self.hosts = Hosts.get()
        self.selectedHost = Hosts.active(hosts: self.hosts)
    }
}
