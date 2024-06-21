//
//  KodioHelpView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI

/// SwiftUI `View` for the help
struct HelpView: View {
    /// The Help model
    @Environment(HelpModel.self) private var help
    /// The presentation mode
    @Environment(\.dismiss) var dismiss
    /// The body of the `View`
    var body: some View {
        @Bindable var help = help
        NavigationSplitView(
            sidebar: {
                List(selection: $help.page) {
                    ForEach(HelpModel.Page.allCases, id: \.self) { help in
                        Text(help.title)
                            .tag(help)
                    }
                }
                .toolbar(removing: .sidebarToggle)
            },
            detail: {
                VStack {
                    Divider()
                    ZStack(alignment: .top) {
                        PartsView.RotatingRecord(
                            title: "Kodio",
                            subtitle: "Play your own music",
                            details: "© Nick Berendsen",
                            rotate: false
                        )
                        .padding()
                        .opacity(0.05)
                        ScrollView {
                            MarkdownView(markdown: help.text)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .toolbar {
                    Image("Record")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                    Text(help.page?.title ?? "")
                }
            }
        )
        .task(id: help.page) {
            Task {
                help.text = HelpModel.getPage(help: help.page ?? .kodioHelp)
            }
        }
    }
}

extension HelpView {

    /// SwiftUI `View` for a help button
    struct HelpButton: View {
        /// The page to show
        var page: HelpModel.Page = .kodioHelp
        /// The Help model
        @Environment(HelpModel.self) private var help
        /// Open Window
        @Environment(\.openWindow) var openWindow

        var body: some View {
            Button(
                action: {
                    help.page = page
                    openWindow(value: KodioApp.Windows.help)
                },
                label: {
                    Label("Help", systemImage: "questionmark.circle.fill")
                }
            )
            .buttonStyle(ButtonStyles.Help())
        }
    }
}
