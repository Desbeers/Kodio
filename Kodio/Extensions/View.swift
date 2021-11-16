//
//  View.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - Extension: ViewContent

extension View {

    /// A general Alert constructor
    func alertContent(content alertItem: AppState.AlertItem) -> Alert {
        guard let primaryButton = alertItem.button else {
            return Alert(title: alertItem.title,
                         message: alertItem.message,
                         dismissButton: alertItem.dismiss != nil ? alertItem.dismiss! : .cancel()
            )
        }
        return Alert(
            title: alertItem.title,
            message: alertItem.message,
            primaryButton: primaryButton,
            secondaryButton: alertItem.dismiss != nil ? alertItem.dismiss! : .cancel()
        )
    }
    
    /// The toolbar shortcut
    /// - Note : macOS and iOS have their own modifier
    func toolbar(basic: Bool = false) -> some View {
        modifier(ViewToolbar(basic: basic))
    }
    
    /// The searchbar shortcut
    func searchbar() -> some View {
        modifier(ViewModifierSearch())
    }
    
    /// Shortcut for macOS specific modifiers
    func macOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(macOS)
        return modifier(self)
        #else
        return self
        #endif
    }

    /// Shortcut for iOS specific modifiers
    func iOS<Content: View>(_ modifier: (Self) -> Content) -> some View {
        #if os(iOS)
        return modifier(self)
        #else
        return self
        #endif
    }
}
