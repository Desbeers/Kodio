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
    @StateObject var help: HelpModel = .shared
    /// The presentation mode
    @Environment(\.dismiss) var dismiss
    /// The body of the `View`
    var body: some View {
        NavigationSplitView(
            sidebar: {
                List(selection: $help.page) {
                    ForEach(HelpModel.Page.allCases, id: \.self) { help in
                        Text(help.title)
                            .tag(help)
                    }
                }
#if os(visionOS)
                /// Add a button to dismiss the Sheet
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark.circle")
                        })
                    }
                }
#endif
            },
            detail: {
                VStack {
                    Divider()
                    ZStack(alignment: .top) {
                        PartsView.RotatingRecord(
                            title: "Kodio",
                            subtitle: "Play your own music",
                            details: "© Nick Berendsen",
                            rotate: .constant(false)
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
        /// Open Window (macOS)
        @Environment(\.openWindow) var openWindow
        /// Open Sheet (other)
        @State private var showSheet: Bool = false
        var body: some View {
            Button(
                action: {
                    HelpModel.shared.page = page
#if os(macOS)
                    openWindow(value: KodioApp.Windows.help)
#else
                    showSheet.toggle()
#endif
                },
                label: {
                    Label("Help", systemImage: "questionmark.circle")
                }
            )
            .sheet(isPresented: $showSheet) {
                HelpView()
                    .foregroundColor(.primary)
            }
        }
    }
}
