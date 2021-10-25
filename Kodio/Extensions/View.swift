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
    
    /// The toolbar
    /// - Note : macOS and iOS have their own modifier
    func toolbar() -> some View {
        modifier(ViewModifierToolbar())
    }
    
    /// The searchbar
    func searchbar() -> some View {
        modifier(ViewModifierSearch())
    }
}
