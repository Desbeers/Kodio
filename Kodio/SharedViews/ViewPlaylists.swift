//
//  ViewPlaylists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// A view with a list of playlists
struct ViewPlaylist: View {
    /// The object that has it all
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        Section(header: Text("Playlists")) {
            ForEach(library.playlists.all) { playlist in
                Button(
                    action: {
                        library.toggleSmartList(smartList: playlist)
                    },
                    label: {
                        Label(playlist.title, systemImage: playlist.icon)
                    }
                )
                    .disabled(playlist == library.smartLists.selected)
                    .animation(nil, value: library.filter)
            }
        }
    }
}
