//
//  ViewAbout.swift
//  Kodio (shared)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// View an 'About' sheet
struct ViewAbout: View {
    /// The view
    var body: some View {
        VStack {
            Text("Kodio")
                .font(.largeTitle)
            Text("Play your own music")
                .font(.headline)
                .padding(.bottom)
            HStack(spacing: 0) {
                Text("A music remote for ")
                Link("Kodi", destination: URL(string: "https://kodi.tv")!)
            }
            Text("For those who are still treasure their **own** music.")
                .font(.caption)
                .padding()
            ViewRotatingRecord()
            if let text = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
                VStack {
                    Text("© Nick Berendsen")
                        .padding(.bottom)
                    HStack(spacing: 0) {
                        Text("Version \(text), GPL-3.0 License, source code on ")
                        
                        Link("GitHub", destination: URL(string: "https://github.com/desbeers/kodio")!)
                    }
                    .font(.caption)
                }
            }
        }
        .padding()
#if os(macOS)
        .frame(minWidth: 500, idealWidth: 500, maxWidth: 500, minHeight: 500, idealHeight: 500, maxHeight: 500, alignment: .top)
#endif
    }
}
