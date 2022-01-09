//
//  AppStateSystem.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import Foundation

extension AppState {
    
    // MARK: The system where Kodio is running
    
    /// Is this a Mac, iPad or an iPhone application?
    enum System: String {
        /// macOS
        case macOS
        /// iPadOS
        case iPad
        /// iOS
        case iPhone
    }
    
}
