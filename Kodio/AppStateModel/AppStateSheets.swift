//
//  AppStateSheets.swift
//  Kodio
//
//  © 2021 Nick Berendsen
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
        /// Show the `Settings` sheet
        /// - Note: only in use for iOS, macOS has its native `Preferences`
        case settings
        /// Show the `About` sheet
        case about
        /// Show the `Help` sheet
        case help
    }
}
