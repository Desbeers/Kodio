//
//  ViewHelp.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View a 'Help' sheet
struct ViewHelp: View {
    /// The help text; dynamic loaded
    @State var help: String = ""
    /// The view
    var body: some View {
        VStack {
            Text("Kodio help")
                .font(.title)
                .padding()
            ZStack(alignment: .top) {
                ViewRotatingRecord()
                    .padding()
                    .opacity(0.05)
            ScrollView {
                VStack {
                    FormattedMarkdown(markdown: help)
                        .padding(.horizontal)
                }
                .padding()
            }
            Spacer()
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .task {
            if let filepath = Bundle.main.url(forResource: "Help", withExtension: "md") {
                do {
                    let contents = try String(contentsOf: filepath)
                    help = contents
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
