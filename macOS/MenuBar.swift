///
/// MenuBar.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

class MenuBarController {
    private var statusItem: NSStatusItem
    private var mainView: NSView
    init(_ view: NSView) {
        self.mainView = view
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "music.note.list",
                                            accessibilityDescription: nil)
            let menuItem = NSMenuItem()
            menuItem.view = mainView
            let menu = NSMenu()
            menu.addItem(menuItem)
            statusItem.menu = menu
        }
    }
}

struct ViewMenuBar: View {
    @StateObject var kodi = KodiClient.shared
    var body: some View {
        HStack {
            RemoteKodiImage(url: kodi.player.item.thumbnail, failure: Image("DefaultCoverArt"))
                .frame(width: 60, height: 60)
                .cornerRadius(5)
            VStack {
                Text(kodi.player.navigationTitle)
                    .font(.headline)
                    .lineLimit(1)
                Text(kodi.player.navigationSubtitle)
                    .font(.subheadline)
                HStack {
                    ViewPlayerButtons().environmentObject(kodi)
                }
            }
        }
        .padding(.horizontal)
    }
}
