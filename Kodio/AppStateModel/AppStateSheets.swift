//
//  AppStateSheets.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension AppState {
    
    // MARK: Sheets for Kodio
    
    /// View a SwiftUI sheet
    /// - Parameter type: One of the ``Sheets``.
    @MainActor func viewSheet(type: Sheets) {
        activeSheet = type
        showSheet = true
    }
    
    /// The different kind of sheets Kodio can present
    enum Sheets {
        /// Show the `Playing Queue` sheet
        case queue
        /// Show the 'Edit Hosts' sheet; iOS only, for macOS it is in its native `Preferences`
        case editHosts
        /// Show the 'Edit Radio' sheet; iOS only, for macOS it is in its native `Preferences`
        case editRadio
        /// Show the `About` sheet
        case about
        /// Show the `Help` sheet
        case help
    }
}
