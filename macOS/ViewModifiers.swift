///
/// ViewModifiers.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ToolbarModifier: ViewModifier {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    func body(content: Content) -> some View {
        Divider()
        content
            .toolbar {
                ToolbarItemGroup {
                    ViewPlayerButtons()
                    Spacer()
                    ViewPlayerOptions()
                    Spacer()
                    ViewPlayerVolume()
                        .frame(width: 160)
                }
                ToolbarItem {
                    ViewSearch()
                        .frame(minWidth: 100, idealWidth: 150, maxWidth: 200)
                }
            }
    }
}

struct AlbumsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}

struct DetailsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
