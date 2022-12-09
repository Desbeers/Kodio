//
//  iPadMenuView.swift
//  Kodio iPad
//
//  Created by Nick Berendsen on 15/08/2022.
//

import SwiftUI

extension MainView {

    /// The iOS toolbar for the sidebar
    @ToolbarContentBuilder func iPadMenu() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                PartsView.HostSelector()
                Divider()
                Button(
                    action: {
                        Task {
                            scene.viewSheet(type: .settings)
                        }
                    },
                    label: {
                        Text("Setttings")
                    }
                )
                Button(
                    action: {
                        Task {
                            scene.viewSheet(type: .help)
                        }
                    },
                    label: {
                        Text("Kodio Help")
                    }
                )
                Button(
                    action: {
                        Task {
                            scene.viewSheet(type: .about)
                        }
                    },
                    label: {
                        Text("About Kodio")
                    }
                )
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}
