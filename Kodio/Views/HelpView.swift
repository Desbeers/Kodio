//
//  KodioHelpView.swift
//  Kodio
//
//  Created by Nick Berendsen on 04/08/2022.
//

import SwiftUI

/// The Help View
struct HelpView: View {
    /// The Help model
    @StateObject var help: HelpModel = .shared
    /// The body of the `View`
    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $help.page) {
                ForEach(HelpModel.Page.allCases, id: \.self) { help in
                    Text(help.title)
                        .tag(help)
                }
            }
        }, detail: {
            VStack {
                Divider()
                ZStack(alignment: .top) {
                    PartsView.RotatingRecord(title: "Kodio",
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
        })
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack {
                    Image("Record")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                    Text(help.page?.title ?? "")
                }
            }
        }
         .task(id: help.page) {
            Task {
                help.text = HelpModel.getPage(help: help.page ?? .kodioHelp)
            }
        }
    }
}
