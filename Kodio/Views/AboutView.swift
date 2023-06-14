//
//  AboutView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI

/// SwiftUI `View` for the about info
struct AboutView: View {
    /// The rotate animation
    @State private var rotate: Bool = true
    /// The body of the `View`
    var body: some View {
        VStack {
            HStack {
                PartsView.RotatingRecord(
                    title: "Kodio",
                    subtitle: "Play your own music",
                    details: "© Nick Berendsen",
                    rotate: $rotate
                )
                .frame(maxWidth: 400)
                VStack {
                    Text("Kodio")
                        .font(.largeTitle)
                        .padding()
                    Text("Play your own music")
                        .font(.headline)
                        .padding(.bottom)
                    HStack(spacing: 0) {
                        Text("A music remote for ")
                        if let link = URL(string: "https://kodi.tv") {
                            Link("Kodi", destination: link)
                        }
                    }
                    Text("For those who are still treasure their **own** music")
                        .font(.caption)
                        .padding()
                    Button(action: {
                        rotate.toggle()
                    }, label: {
                        Text(rotate ? "Stop the record pleaae" : "Start the record again")
                    })
                    .padding(.bottom)
                    Text("© Nick Berendsen")
                        .padding(.bottom)
                }
            }
            if let text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                HStack(spacing: 0) {
                    Text("Version \(text), GPL-3.0 License, source code on ")
                    if let link = URL(string: "https://github.com/desbeers/kodio") {
                        Link("GitHub", destination: link)
                    }
                }
                .font(.caption)
                .padding(.bottom)
            }
        }
        .frame(minWidth: 600, maxWidth: 600, minHeight: 400, maxHeight: 400)
    }
}
