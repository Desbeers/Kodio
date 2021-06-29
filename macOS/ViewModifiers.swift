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
    /// State of the seachfield in the toolbar
    @State private var search = ""
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup {
                    ViewPlayerVolume()
                        .frame(width: 160)
                    Spacer()
                    ViewPlayerButtons()
                    Spacer()
                    ViewPlayerOptions()
                }
                ToolbarItemGroup {
                    ViewPlaylistMenu()
                    ViewRadioMenu()
                }
                ToolbarItem {
                    SearchField(search: $search, kodi: kodi)
                        .frame(minWidth: 100, idealWidth: 150, maxWidth: 200)
                }
            }
    }
}

struct DetailsModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
    }
}
