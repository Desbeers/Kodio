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
/// - Checks what system is running Kodio
/// - Showing sheets
/// - Showing alerts
final class AppState: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// The shared instance of this AppState class
    static let shared = AppState()
    /// Bool to show or hide a SwiftUI sheet
    @Published var showSheet: Bool = false
    /// Define what kind of sheet to show
    var activeSheet: Sheets = .queue
    /// The struct for a SwiftUI Alert item
    @Published var alert: AlertItem?
    /// The state of Kodio
    @Published var state: State = .none
    /// The sidebar items
    @Published var sidebarItems: [Library.LibraryListItem] = []
    /// Check if Kodio is running on a Mac or on an iOS device
    /// - Note:The iOS app thingy will override this `var` if Kodio is not running on a Mac
    var system: System = .macOS
    
    // MARK: Init the AppState class
    
    /// Do a private init to make sure we have only one instance of the AppState class
    private init() {}
}
