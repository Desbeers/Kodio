//
//  StartView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the start
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
    /// The body of the `View`
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    ProgressView()
                    /// 'tint' does not work on macOS here
                        .colorInvert()
                        .brightness(1)
                        .opacity(kodi.status == .loadedLibrary ? 0 : 1)
                    Spacer()
                }
                if kodi.configuredHosts.isEmpty {
                    noHostConfigured
                } else {
                    if !kodi.host.ip.isEmpty {
                        hostActions
                    }
                    HStack {
                        Spacer()
                        otherHosts
                    }
                }
            }
            .modifier(PartsView.ListHeader())
            PartsView.RotatingRecord(
                icon: "music.quarternote.3",
                subtitle: kodi.host.bonjour?.name ?? "Kodio",
                details: kodi.status.message,
                rotate: $rotate
            )
        }
        .task(id: kodi.status) {
            rotate = kodi.status == .loadedLibrary ? true : false
        }
    }
    ///  View when no hst is configured
    var noHostConfigured: some View {
        VStack {
            Text("Welcome to Kodio!")
                .font(.title)
            Text("There is no host configured")
                .font(.caption)
                .opacity(0.6)
            Button(action: {
#if os(macOS)
                NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
#else
                appState.selection = .appSettings
#endif
            }, label: {
                Text("Add a host")
            })
            .buttonStyle(ButtonStyles.Play())
        }
    }
    /// View for actions for the selected host
    var hostActions: some View {
        VStack {
            Text(kodi.host.name)
                .font(.title)
            Text(kodi.status.message)
                .font(.caption)
                .opacity(0.6)
            Button(action: {
                Task {
                    await kodi.loadLibrary(cache: false)
                }
            }, label: {
                Label(title: {
                    Text("Reload Library")
                }, icon: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                })
            })
            .disabled(kodi.status != .loadedLibrary && kodi.status != .outdatedLibrary)
            .buttonStyle(ButtonStyles.HostAction())
        }
    }
    /// Optional View for other configured hosts
    var otherHosts: some View {
        VStack(alignment: .leading) {
            ForEach(
                kodi
                    .configuredHosts
                    .filter { $0.ip != kodi.host.ip },
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
                                .opacity(0.6)
                        }
                    }, icon: {
                        Image(systemName: "globe")
                            .foregroundColor(host.isOnline ? .accentColor : .red)
                    })
                })
                .disabled(!host.isOnline || kodi.status == .loadingLibrary)
                .padding(.bottom, 2)
            }
        }
        .buttonStyle(.plain)
    }
}
