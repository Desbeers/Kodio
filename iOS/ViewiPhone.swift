//
//  ViewiPhone.swift
//  Kodio (iOS)
//
//  Created by Nick Berendsen on 04/06/2021.
//

import SwiftUI

struct ViewiPhone: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    var body: some View {
        TabView {
            ViewiPhoneMain()
                .tabItem {
                    Label("Home", systemImage: "music.note.house")
                }
            
            ViewPlaylistQueue()
                .tabItem {
                    Label("Queue", systemImage: "music.note.list")
                }
            VStack(spacing: 20) {
                ViewKodiHostsMenu()
            }
            .tabItem {
                Label("Host", systemImage: "gearshape")
            }
        }
    }
}

struct ViewiPhoneMain: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text(kodi.player.navigationTitle)
                        .font(.headline)
                    Text(kodi.player.navigationSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color.secondary.opacity(0.2))
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    ViewRadioMenu()
                }
            }
            .padding()
            Spacer()
            VStack(spacing: 50) {
                HStack {
                    ViewPlayerButtons()
                }
                .scaleEffect(1.5)
                HStack {
                    ViewPlayerOptions()
                }
                .scaleEffect(1.2)
                ViewPlayerVolume()
                    .frame(width: 160)
            }
            .buttonStyle(ViewPlayerStyleButton())
            Spacer()
        }
    }
}
