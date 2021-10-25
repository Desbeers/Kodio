//
//  ViewPlaylists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View description

/// A view with a list of playlists
struct ViewPlaylist: View {
    /// The object that has it all
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        Section(header: Text("Playlists")) {
            ForEach(library.allPlaylists) { playlist in
                Button(
                    action: {
                        library.toggleSmartList(smartList: playlist)
                    },
                    label: {
                        Label(playlist.title, systemImage: playlist.icon)
//                        HStack {
//                            Image(systemName: playlist.icon)
//                                .foregroundColor(.accentColor)
//                                .frame(width: 16)
//                            Text(playlist.title)
//                            Spacer()
//                        }
                    }
                )
                    .disabled(playlist == library.selectedSmartList)
                    .animation(nil, value: library.media)
            }
        }
    }
}
