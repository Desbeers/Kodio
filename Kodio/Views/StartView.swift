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
            Group {
                if kodi.configuredHosts.isEmpty {
                    noHostConfigured
                } else {
                    if !kodi.host.ip.isEmpty {
                        hostActions
                            .overlay(alignment: .leading) {
                                loadingSpinner
                                /// 'tint' does not work on macOS here
                                    .colorInvert()
                                    .brightness(1)
                            }
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
    /// Spinner when loading
    @ViewBuilder var loadingSpinner: some View {
        switch kodi.status {
        case .loadingLibrary, .updatingLibrary, .connectedToWebSocket:
            ProgressView()
        default:
            EmptyView()
        }
    }
    ///  View when no host is configured
    var noHostConfigured: some View {
        VStack {
            Text("Welcome to Kodio!")
                .font(.title)
            Text("There is no host configured")
                .font(.caption)
                .opacity(0.6)

#if os(macOS)
            if #available(macOS 14, *) {
                SettingsLink {
                    Text("Add a host")
                }
                .playButtonStyle()
            } else {
                Button(action: {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }, label: {
                    Text("Add a host")
                })
                .playButtonStyle()
            }
#else
            Button(action: {
                appState.selection = .appSettings
            }, label: {
                Text("Add a host")
            })
            .playButtonStyle()
#endif
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
        }
        .frame(maxWidth: .infinity)
        .overlay(alignment: .trailing) {
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
            .playButtonStyle()
        }
    }
}
