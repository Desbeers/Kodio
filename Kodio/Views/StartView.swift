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
    @Environment(AppState.self) private var appState
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// Rotate the record
    @State private var rotate: Bool = false
    /// The loading status of the View
    @State private var status: ViewStatus = .loading
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
            switch status {
            case .ready:
//                Group {
//                    if kodi.configuredHosts.isEmpty {
//                        noHostConfigured
//                    } else {
//                        if !kodi.host.ip.isEmpty {
//                            hostActions
//                                .overlay(alignment: .leading) {
//                                    loadingSpinner
//                                    /// 'tint' does not work on macOS here
//                                        .colorInvert()
//                                        .brightness(1)
//                                }
//                        }
//                    }
//                }
//                .modifier(PartsView.ListHeader())
                PartsView.RotatingRecord(
                    icon: "music.quarternote.3",
                    subtitle: kodi.host.bonjour?.name ?? "Kodio",
                    details: kodi.status.message,
                    rotate: rotate
                )
                .overlay(alignment: .bottom) {
                    if rotate {
                        RandomItemsView()
                            .transition(.move(edge: .bottom))
                    }
                }
            default:
                status.message(router: appState.selection)
            }
        }
        .animation(.default, value: status)
        .animation(.default, value: rotate)
        .task {
            status = .ready
        }
        .task(id: kodi.status) {
            try? await Task.sleep(until: .now + .seconds(1), clock: .continuous)
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
            SettingsLink {
                Text("Add a host")
            }
            .playButtonStyle()
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
