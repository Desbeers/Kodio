//
//  ViewSmartLists.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View smart lists

struct ViewSmartLists: View {
    /// The Library model
    @EnvironmentObject var library: Library
    /// The view
    var body: some View {
        Section(header: ViewAppStateStatus()) {
            ForEach(library.allSmartLists) { list in
                Button(
                    action: {
                        library.toggleSmartList(smartList: list)
                    },
                    label: {
                        Label(list.title, systemImage: list.icon)
                    }
                )
                    .disabled(list == library.selectedSmartList)
                    .animation(nil, value: library.media)
            }
            ViewSearchButton()
        }
    }
}
