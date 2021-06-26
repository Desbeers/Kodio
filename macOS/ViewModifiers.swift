///
/// ViewModifiers.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ToolbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct SmartListsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(height: 168)
    }
}

struct DetailsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
