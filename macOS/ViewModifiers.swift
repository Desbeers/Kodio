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
    /// Search
    @StateObject var searchObserver = SearchFieldObserver.shared
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false
    func body(content: Content) -> some View {
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
                    SearchField(search: $searchObserver.searchText)
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
