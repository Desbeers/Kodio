//
//  SettingsView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for the settings
struct SettingsView: View {
    /// The AppState model
    @Environment(AppState.self) private var appState
    /// The selected tab
    @State private var selection: Tabs = .kodiHosts
    /// The body of the `View`
    var body: some View {
        @Bindable var appState = appState
        VStack {
#if os(macOS)
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
#else
            VStack(spacing: 0) {
                HStack {
                    Button(
                        action: { selection = .kodiHosts },
                        label: { Tabs.kodiHosts.label }
                    )
                    Button(
                        action: { selection = .sidebar },
                        label: { Tabs.sidebar.label }
                    )
                    Button(
                        action: { selection = .playback },
                        label: { Tabs.playback.label }
                    )
                    HelpView.HelpButton()
                    Button(
                        action: { selection = .about },
                        label: { Tabs.about.label }
                    )
                }
                .playButtonStyle()
                .padding()
                .modifier(PartsView.ListHeader())
                VStack {
                    switch selection {
                    case .kodiHosts:
                        HostsView()
                    case .sidebar:
                        Sidebar(settings: $appState.settings)
                    case .playback:
                        Playback(settings: $appState.settings)
                    case .help:
                        HelpView()
                    case .about:
                        AboutView()
                    }
                }
                .frame(maxWidth: 800)
            }
#endif
        }
        .animation(.default, value: selection)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        /// Store the settings when they are changed
        .onChange(of: appState.settings) { _, settings in
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
        /// Help
        case help
        /// About
        case about
        /// The `Label` for a tab
        var label: some View {
            switch self {
            case .kodiHosts:
                Label("Kodi Hosts", systemImage: "gear")
            case .sidebar:
                Label("Sidebar", systemImage: "sidebar.leading")
            case .playback:
                Label("Playback", systemImage: "play.fill")
            case .help:
                Label("Help", systemImage: "questionmark.circle.fill")
            case .about:
                Label("About", systemImage: "info.circle")
            }
        }
    }
}

extension SettingsView {

    /// The Playback settings
    struct Playback: View {
        /// The AppState model
        @Environment(AppState.self) private var appState
        /// The KodiConnector model
        @Environment(KodiConnector.self) private var kodi
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
                    Text(
                        appState.settings.togglePlayerSettings ?
                        "Kodio takes care of these settings" : "Change settings on you selected Kodi"
                    )
                    .foregroundColor(appState.settings.togglePlayerSettings ? .red : .primary)
                    .font(.caption)
                    VStack(alignment: .leading) {
                        KodiSettingView.SingleSetting(setting: .musicplayerCrossfade)
                        KodiSettingView.SingleSetting(setting: .musicPlayerReplayGainType)
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
                // swiftlint:disable:next line_length
                Text("When enabled, Kodio will adjust the *Volume adjustment*  and *Crossfade* settings on your Kodi depending on your selection to play.")
                    .font(.caption)
                HelpView.HelpButton(page: .playerSettings)
                    .playButtonStyle()
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
                    .disabled(
                        !settings.crossfadePlaylists && !settings.crossfadeCompilations && !settings.crossfadePartyMode
                    )
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
        @Environment(AppState.self) private var appState
        /// All the Kodio settings
        @Binding var settings: KodioSettings
        /// The body of the `View`
        var body: some View {
            VStack {
                Text("Sidebar Items")
                    .font(.title)
                VStack(alignment: .leading) {
#if os(macOS)
                    Toggle(isOn: $settings.showMusicMatch) {
                        VStack(alignment: .leading) {
                            Text("Show Music Match")
                            Text(Router.musicMatch.item.description)
                                .font(.caption)
                        }
                    }
#endif
                    Toggle(isOn: $settings.showMusicVideos) {
                        VStack(alignment: .leading) {
                            Text("Show Music Videos")
                            Text(Router.musicVideos.item.description)
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
