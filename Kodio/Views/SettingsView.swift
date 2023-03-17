//
//  SettingsView.swift
//  Kodio
//
//  Created by Nick Berendsen on 09/08/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Settings View
struct SettingsView: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The selected tab
    @State var selection: Tabs = .kodiHosts
    /// The body of the `View`
    var body: some View {
        TabView(selection: $selection) {
            HostsView()
                .tabItem {
                    Label("Kodi Hosts", systemImage: "gear")
                }
                .tag(Tabs.kodiHosts)
            Sidebar(settings: $appState.settings)
                .tabItem {
                    Label("Sidebar", systemImage: "sidebar.leading")
                }
                .tag(Tabs.sidebar)
            Playback(settings: $appState.settings)
                .tabItem {
                    Label("Playback", systemImage: "play.fill")
                }
                .tag(Tabs.playback)
        }
        .animation(.default, value: selection)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        /// Store the settings when they are changed
        .onChange(of: appState.settings) { settings in
            appState.updateSettings(settings: settings)
        }
    }

    /// The tabs of the ``SettingsView``
    enum Tabs {
        /// Host setiings
        case kodiHosts
        /// Sidebar settings
        case sidebar
        /// Playback settings
        case playback
    }
}

extension SettingsView {

    /// The Playback settings
    struct Playback: View {
        /// The AppState model
        @EnvironmentObject var appState: AppState
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// All the Kodio settings
        @Binding var settings: KodioSettings
        /// Open Window
        @Environment(\.openWindow) var openWindow
        /// The body of the `View`
        var body: some View {
            ScrollView {
                VStack {
                    Label(title: {
                        Text("Kodio")
                    }, icon: {
                        Image("Record")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    })
                    .font(.title)
                    .padding()
                    kodioSettings
                    Label(title: {
                        Text("\(kodi.host.name)")
                    }, icon: {
                        Image("KodiLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    })
                    .font(.title)
                    .padding(.top)
                    Text(appState.settings.togglePlayerSettings ? "Kodio takes care of these settings" : "Change settings on you selected Kodi")
                        .foregroundColor(appState.settings.togglePlayerSettings ? .red : .primary)
                        .font(.caption)
                    VStack(alignment: .leading) {
                        KodiSettingView.setting(for: .musicplayerCrossfade)
                        KodiSettingView.setting(for: .musicPlayerReplayGainType)
                    }
                    .disabled(appState.settings.togglePlayerSettings)
                }
                .padding(.horizontal)
            }
            .animation(.default, value: kodi.settings)
            .animation(.default, value: appState.settings)
        }
        /// The Kodio settings for Playback
        var kodioSettings: some View {
            VStack(alignment: .leading) {
                Toggle(isOn: $settings.togglePlayerSettings) {
                    Text("Adjust the *Kodi Music Player* settings on playback")
                }
                Text("When enabled, Kodio will adjust the *Volume adjustment*  and *Crossfade* settings on your Kodi depending on your selection to play.")
                    .font(.caption)
                Button(action: {
                    HelpModel.shared.page = .playerSettings
                    openWindow(value: KodioApp.Windows.help)
                }, label: {
                    Label("Help", systemImage: "questionmark.circle.fill")
                })
                .buttonStyle(ButtonStyles.Help())
                .frame(maxWidth: .infinity, alignment: .trailing)
                if settings.togglePlayerSettings {
                    Toggle(isOn: $settings.crossfadePlaylists) {
                        Text("*Crossfade* songs when playing a playlist")
                    }
                    Toggle(isOn: $settings.crossfadeCompilations) {
                        Text("*Crossfade* songs on compilation albums")
                    }
                    Toggle(isOn: $settings.crossfadePartyMode) {
                        Text("*Crossfade* songs when in Party Mode")
                    }
                    Text("*Norml* albums will never crossfade.")
                        .font(.caption)
                    Picker("Duration of the crossfade", selection: $settings.crossfade) {
                        ForEach(1...10, id: \.self) { value in
                            Text("\(value) seconds")
                        }
                    }
                    .disabled(!settings.crossfadePlaylists && !settings.crossfadeCompilations && !settings.crossfadePartyMode)
                }

            }
            .padding()
            .background(.thickMaterial)
            .cornerRadius(10)
        }
    }
}

extension SettingsView {

    /// The ``SidebarView`` settings
    struct Sidebar: View {
        /// The AppState model
        @EnvironmentObject var appState: AppState
        /// All the Kodio settings
        @Binding var settings: KodioSettings
        /// The body of the `View`
        var body: some View {
            VStack {
                Text("Sidebar Items")
                    .font(.title)
                VStack(alignment: .leading) {
                    Toggle(isOn: $settings.showMusicMatch) {
                        VStack(alignment: .leading) {
                            Text("Show Music Match")
                            Text(Router.musicMatch.sidebar.description)
                                .font(.caption)
                        }
                    }
                    Toggle(isOn: $settings.showMusicVideos) {
                        VStack(alignment: .leading) {
                            Text("Show Music Videos")
                            Text(Router.musicVideos.sidebar.description)
                                .font(.caption)
                        }
                    }
                    Toggle(isOn: $settings.showRadioStations) {
                        VStack(alignment: .leading) {
                            Text("Show Radio Stations")
                            Text("Show the list of Radio Stations")
                                .font(.caption)
                        }
                    }
                }
                Text("Favourites")
                    .font(.title2)
                    .padding(.top)
                VStack(alignment: .leading) {
                    Picker("Minimum rating of a song", selection: $settings.userRating) {
                        ForEach(1...10, id: \.self) { value in
                            Text("Rating of \(value)")
                        }
                    }
                    .frame(width: 200)
                    .labelsHidden()
                        Text("Minimum rating you gave a song to be viewed in Favourites.")
                            .padding(.bottom)
                            .font(.caption)
                        Label(title: {
                            Text("_This it not the content of the **Kodi Favourites** menu item_.")
                        }, icon: {
                            Image(systemName: "info.circle.fill")
                        })
                }

            }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}
