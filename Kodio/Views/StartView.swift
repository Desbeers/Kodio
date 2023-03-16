//
//  StartView.swift
//  Kodio
//
//  Created by Nick Berendsen on 11/08/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The View that will be shown when Kodio is starting
struct StartView: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The SceneState model
    @EnvironmentObject var scene: SceneState
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// Rotate the record
    @State private var rotate: Bool = false
    /// The record animation
    var foreverAnimation: Animation {
        Animation.linear(duration: 3.6)
            .repeatForever(autoreverses: false)
    }
    /// The body of the `View`
    var body: some View {
        ZStack(alignment: .center) {
            PartsView.RotatingRecord(icon: "music.quarternote.3",
                                     subtitle: kodi.host.bonjour?.name ?? "Kodio",
                                     details: kodi.status.message,
                                     rotate: $rotate
            )
            if kodi.status == .none {
                VStack {
                    Text("Welcome to Kodio!")
                        .font(.title)
                    Text("There is no host configured")
                        .font(.subheadline)
                    Button(action: {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }, label: {
                        Text("Add a host")
                    })
                }
                .padding()
                .background(.ultraThickMaterial)
                .cornerRadius(10)
            }
        }
        .task(id: kodi.status) {
            rotate = kodi.status == .loadedLibrary ? true : false
        }
    }
}
