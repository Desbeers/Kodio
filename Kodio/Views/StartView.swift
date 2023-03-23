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
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// Rotate the record
    @State private var rotate: Bool = false
    /// The record animation
    var foreverAnimation: Animation {
        Animation.linear(duration: 3.6)
            .repeatForever(autoreverses: false)
    }
    /// The body of the View
    var body: some View {
        ZStack(alignment: .topLeading) {
            PartsView.RotatingRecord(
                icon: "music.quarternote.3",
                subtitle: kodi.host.bonjour?.name ?? "Kodio",
                details: kodi.status.message,
                rotate: $rotate
            )
            VStack {
                if kodi.configuredHosts.isEmpty {
                    noHostConfigured
                } else {
                    HStack {
                        if !kodi.host.ip.isEmpty {
                            hostActions
                                .frame(width: 400)
                        }
                        otherHosts
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thickMaterial)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
            )
            .padding()
        }
        .animation(.default, value: kodi.status)
        .animation(.default, value: kodi.configuredHosts)
        .task(id: kodi.status) {
            rotate = kodi.status == .loadedLibrary ? true : false
        }
    }
    ///  View when no hst is configured
    var noHostConfigured: some View {
        VStack {
            Text("Welcome to Kodio!")
                .font(.title)
                .padding()
            Text("There is no host configured")
                .font(.subheadline)
            Button(action: {
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
            }, label: {
                Text("Add a host")
            })
            .padding()
        }
    }
    /// View for actions for the selected host
    var hostActions: some View {
        VStack {
            Text(kodi.host.name)
                .font(.title)
            Text(kodi.status.message)
                .font(.caption)
            Button(action: {
                Task {
                    await kodi.loadLibrary(cache: false)
                }
            }, label: {
                Text("Reload Library")
            })
            .disabled(kodi.status != .loadedLibrary && kodi.status != .outdatedLibrary)
        }
    }
    /// Optional View for other configured hosts
    var otherHosts: some View {
        VStack {
            ForEach(
                kodi
                    .configuredHosts
                    .filter { $0.status == .configured && $0.ip != kodi.host.ip },
                id: \.ip
            ) { host in
                Button(action: {
                    kodi.connect(host: host)
                }, label: {
                    Label(title: {
                        VStack(alignment: .leading) {
                            Text(host.name)
                            Text(host.isOnline ? "Online" : "Offline")
                                .font(.caption)
                        }
                        .frame(width: 200, alignment: .leading)
                    }, icon: {
                        Image(systemName: "globe")
                            .foregroundColor(host.isOnline ? host.isSelected ? .green : .accentColor : .red)
                    })
                })
                .disabled(!host.isOnline || kodi.status == .loadingLibrary)
            }
        }
        .buttonStyle(.plain)
    }
}
