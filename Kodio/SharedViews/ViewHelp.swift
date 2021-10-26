//
//  ViewHelp.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct ViewHelp: View {
    @State var help: String = ""
    @State var animate: Bool = false
    
    var body: some View {
        VStack {
            Text("Kodio help")
                .font(.title)
                .padding()
            ZStack(alignment: .top) {
                ViewKodiRotatingIcon(animate: $animate)
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
            animate = true
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
