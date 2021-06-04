///
/// SearchField.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - NSViewRepresentable: SearchField

struct SearchField: NSViewRepresentable {
    /// The search string
    @Binding var search: String
    /// The object that has it all
    var kodi: KodiClient

    class Coordinator: NSObject, NSSearchFieldDelegate {
        var parent: SearchField
        init(_ parent: SearchField) {
            self.parent = parent
        }
        func controlTextDidChange(_ notification: Notification) {
            guard let searchField = notification.object as? NSSearchField else {
                return
            }
            /// Pass the new value to the view
            parent.kodi.searchUpdate(text: searchField.stringValue)
        }
    }

    func makeNSView(context: Context) -> NSSearchField {
        NSSearchField(frame: .zero)
    }

    func updateNSView(_ searchField: NSSearchField, context: Context) {
        searchField.stringValue = search
        searchField.delegate = context.coordinator
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

// MARK: - SearchField (Extension)

/// Hide the focus ring
extension NSSearchField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
