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
    /// The View    
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
        /// Stire the settings when they are changed
        .onChange(of: appState.settings) { settings in
            appState.updateSettings(settings: settings)
        }
    }
    
    /// The tabs of the ``SettingsView``
    enum Tabs {
        case kodiHosts
        case sidebar
        case playback
    }
}

extension SettingsView {
    
    /// The Playback settings
    struct Playback: View {
        /// The AppState model
        @EnvironmentObject var appState: AppState
        /// The SceneState model
        @EnvironmentObject var scene: SceneState
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// All the Kodio settings
        @Binding var settings: KodioSettings
        /// Open Window
        @Environment(\.openWindow) var openWindow
        /// The View
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
                        Text("\(kodi.host.description)")
                    }, icon: {
                        Image("KodiLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    })
                    .font(.title)
                    .padding(.top)
                    Text("Change settings on you selected Kodi")
                        .font(.caption)
                    VStack(alignment: .leading) {
                        ForEach(kodi.settings.filter({$0.parent == .unknown})) { setting in
                            KodiSetting(setting: setting)
                                .padding(.bottom)
                        }
                    }
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
                    Text("Adjust the *Music Player* settings on playback")
                }
                Text("When enabled, Kodio will adjust the *Volume adjustment*  and *Crossfade* settings in your Kodi depending on your selection to play.")
                    .font(.caption)
                Button(action: {
                    HelpModel.shared.page = .replayGain
#if os(macOS)
                    self.openWindow(value: KodioApp.Window.help)
#else
                    scene.viewSheet(type: .help)
#endif
                }, label: {
                    Label("Help", systemImage: "questionmark.circle.fill")
                })
                .buttonStyle(ButtonStyles.Help())
                .frame(maxWidth: .infinity, alignment: .trailing)
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
        /// The View
        var body: some View {
                VStack {
                    Text("Sidebar Settings")
                        .font(.title)
                    VStack(alignment: .leading) {
#if os(macOS)
                        Toggle(isOn: $settings.showMusicMatch) {
                            VStack(alignment: .leading) {
                                Text("Show Music Match")
                                Text(Router.musicMatch.sidebar.description)
                                    .font(.caption)
                            }
                        }
#endif
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
                }
            .padding()
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

extension SettingsView {
    
    /// The View for a Kodi Setting
    struct KodiSetting: View {
        /// The AppState model
        @EnvironmentObject var appState: AppState
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The Kodi setting
        @State var setting: Setting.Details.Base
        /// The View
        var body: some View {
            VStack(alignment: .leading) {
                switch setting.control.widget {
                case .list:
                    Text(setting.label)
                        .font(setting.parent == .unknown ? .title2 : .headline)
                    Picker(setting.label, selection: $setting.valueInt) {
                        ForEach(setting.settingInt ?? [Setting.Details.SettingInt](), id: \.self) { option in
                            Text(option.label)
                                .tag(option.value)
                        }
                    }
                    .labelsHidden()
                    .disabled(KodioSettings.disabled(setting: setting.id))
                case .spinner:
                    Text(setting.label)
                        .font(setting.parent == .unknown ? .title2 : .headline)
                    Picker(setting.label, selection: $setting.valueInt) {
                        
                        ForEach((setting.minimum...setting.maximum), id: \.self) { value in
                            
                            Text(value == 0 ? setting.control.minimumLabel : formatLabel(value: value))
                                .tag(value)
                        }
                        
                        ForEach(setting.settingInt ?? [Setting.Details.SettingInt](), id: \.self) { option in
                            Text(option.label)
                                .tag(option.value)
                        }
                    }
                    .labelsHidden()
                    .disabled(KodioSettings.disabled(setting: setting.id))
                case .toggle:
                    Toggle(setting.label, isOn: $setting.valueBool)
                        .disabled(KodioSettings.disabled(setting: setting.id))
                default:
                    Text("Setting \(setting.control.widget.rawValue) is not implemented")
                        .font(.caption)
                }
                
                Text(setting.help)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
                Text(KodioSettings.disabled(setting: setting.id) ? "Kodio takes care of this setting" : "")
                    .font(.caption)
                    .foregroundColor(.red)
                /// Recursive load child settings
                ForEach(kodi.settings.filter({$0.parent == setting.id && $0.enabled})) { child in
                    KodiSetting(setting: child)
                        .padding(.top)
                }
            }
            .padding(setting.parent == .unknown ? .all : .horizontal)
            .background(.thickMaterial)
            .cornerRadius(10)
            .animation(.default, value: appState.settings)
            .onChange(of: setting.valueInt) { _ in
                Task { @MainActor in
                    await Settings.setSettingValue(setting: setting.id, int: setting.valueInt)
                    /// Get the settings of the host
                    kodi.settings = await Settings.getSettings()
                }
            }
            .onChange(of: setting.valueBool) { _ in
                Task { @MainActor in
                    await Settings.setSettingValue(setting: setting.id, bool: setting.valueBool)
                    /// Get the settings of the host
                    kodi.settings = await Settings.getSettings()
                }
            }
        }
        
        func formatLabel(value: Int) -> String {
            let labelRegex = /{0:d}(?<label>.+?)/
            
            if let result = setting.control.formatLabel.wholeMatch(of: labelRegex) {
                
                return "\(value)\(result.label)"
                
            } else {
                return "\(value)"
            }
            
        }
    }
}
