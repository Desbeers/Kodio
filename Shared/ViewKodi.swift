///
/// ViewKodi.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewKodiHostsMenu (view)

/// The Kodi host selector
struct ViewKodiHostsMenu: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        Divider()
        Picker("Kodi Hosts", selection: $kodi.selectedHost) {
            ForEach(kodi.hosts) { host in
                Text(host.description).tag(host as HostFields)
            }
        }
        .pickerStyle(InlinePickerStyle())
        .onChange(of: kodi.selectedHost) { host in
            kodi.selectHost(selected: host)
        }
        #if os(macOS)
        Button("Edit list") {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        #endif
        #if os(iOS)
        Button("Edit list") {
            DispatchQueue.main.async {
                appState.activeSheet = .editHosts
                appState.showSheet = true
            }
        }
        #endif
        if kodi.library.all {
            Button("Reload Library") {
                kodi.getLibrary(reload: true)
            }
        }
    }
}

struct ViewKodiStatus: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    var body: some View {
        VStack {
            if !kodi.libraryUpToDate {
                Text("Your library is out of date")
            }
            if kodi.libraryIsScanning {
                ProgressView("Scanning the music library on '\(kodi.selectedHost.description)'")
            }
        }
        .font(.caption)
    }
}

// MARK: - ViewKodiLoading (view)

struct ViewKodiLoading: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        VStack {
            if kodi.library.online {
                Text("Connecting to '\(kodi.selectedHost.description)'")
                    .font(.title)
                    .padding(.bottom, 40)
            } else if kodi.hosts.isEmpty {
                Text("You don't have any Kodi configured")
                    .font(.headline)
                /// Open Preferences in macOS and a sheet in iOS
                #if os(macOS)
                Button("Add a Kodi") {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
                #endif
                #if os(iOS)
                Button("Add a Kodi") {
                    DispatchQueue.main.async {
                        appState.activeSheet = .editHosts
                        appState.showSheet = true
                    }
                }
                #endif
                ViewKodiServiceSettings()
            } else {
                if kodi.selectedHost.ip.isEmpty {
                    Text("You have no Kodi selected")
                        .font(.headline)
                } else {
                    Text("Your Kodi is offline")
                        .font(.headline)
                    Text("'\(kodi.selectedHost.description)' is not available")
                        .font(.subheadline)
                }
                Menu("Select Kodi Host") {
                    ViewKodiHostsMenu()
                }
                .frame(maxWidth: 200)
                ViewKodiServiceSettings()
            }
        }
    }
}

// MARK: ViewKodiServiceSettings (view)

/// Some basic instructions how to enabe Kodi remote control
struct ViewKodiServiceSettings: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Make sure remote control is enabled in Kodi")
                .font(.headline)
            Text("Turn on the following settings in Kodi to enable using this remote control:")
            Group {
                Text("Settings → Services → Control → Allow programs on other systems to control Kodi → ON")
                Text("Settings/Services/Control → Allow control of Kodi via HTTP → ON")
            }
            .font(.system(.callout, design: .monospaced))
            Text("Take note of the Port number, the Username and the Password (if any).")
        }
        .padding()
    }
}
    
// MARK: ViewKodiRotatingIcon (view)

struct ViewKodiRotatingIcon: View {
    /// Rotating image
    @State private var isAnimating = false
    var rotateRecord: Animation {
        Animation.linear(duration: 3.6)
            .repeatForever(autoreverses: false)
    }
    var stopRecord: Animation {
        Animation.linear(duration: 0)
    }
    var body: some View {
        Image("Record")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(Angle(degrees: self.isAnimating ? 360 : 0.0))
            .animation(isAnimating ? rotateRecord : stopRecord)
            .onAppear {
                /// Give it a moment to settle; else the animation is strange on macOS
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isAnimating = true
                }
            }
    }
}

// MARK: - ViewKodiEditHosts (view)

struct ViewKodiEditHosts: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// Selected host
    @State var selectedHost: HostFields?
    /// The view
    var body: some View {
        HStack(spacing: 0) {
            List {
                if !kodi.hosts.isEmpty {
                    Section(header: Text("Your Kodi's")) {
                        ForEach(kodi.hosts) { host in
                            HStack {
                                Text(host.description)
                                Spacer()
                            }
                            /// Make the whole listitem clickable
                            .contentShape(Rectangle())
                            .onTapGesture(perform: {
                                selectedHost = host
                            })
                            .padding()
                            .if(host == selectedHost) {
                                $0.background(Color.accentColor).foregroundColor(.white)
                            }
                            .cornerRadius(5)
                        }
                    }
                }
                Section(header: Text("New")) {
                    Label("Add a new Kodi", systemImage: "plus.circle")
                        .onTapGesture(perform: {
                            selectedHost = HostFields()
                        })
                        .padding()
                }
            }
            .frame(maxWidth: 200)
            .listStyle(SidebarListStyle())
            VStack {
                if selectedHost != nil {
                    ViewKodiEditDetails(selectedHost: $selectedHost)
                } else {
                    Text("Select a Kodi")
                        .font(.title)
                    ViewKodiServiceSettings()
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            /// Start with a new Kodi if we have none
            if kodi.hosts.isEmpty {
                selectedHost = HostFields()
            }
        }
    }
}

// MARK: - ViewKodiEditDetails (view)

struct ViewKodiEditDetails: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    @Binding var selectedHost: HostFields?
    /// The States for the form
    @State private var description = ""
    @State private var ip = ""
    @State private var port = ""
    @State private var tcp = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var selected: Bool = false
    /// Check what host we are editing
    var index: Int? {
        guard let index = kodi.hosts.firstIndex(of: selectedHost ?? HostFields()) else {
            return nil
        }
        return index
    }
    /// The view
    var body: some View {
        VStack {
            Form {
                Section(footer: ViewKodiEditFooter(text: "The name of your Kodi")) {
                    TextField("Name", text: $description)
                }
                Section(footer: ViewKodiEditFooter(text: "The ip address of your Kodi")) {
                    TextField("127.0.0.1", text: $ip)
                }
                Section(footer: ViewKodiEditFooter(text: "The TCP and UDP ports")) {
                    HStack(spacing: 10) {
                        TextField("8080", text: $port)
                        TextField("9090", text: $tcp)
                    }
                }
                Section(footer: ViewKodiEditFooter(text: "Your username and password")) {
                    HStack(spacing: 10) {
                        TextField("username", text: $username)
                        TextField("password", text: $password)
                    }
                }
                Section {
                    HStack {
                        if let index = index {
                            /// We are editing a host
                            Button("Update") {
                                let updatedHost = saveHost()
                                kodi.hosts[index] = updatedHost
                                selectedHost = updatedHost
                                saveAllHosts(hosts: kodi.hosts)
                            }
                            Spacer()
                            Button("Delete") {
                                kodi.hosts.remove(at: index)
                                saveAllHosts(hosts: kodi.hosts)
                                selectedHost = nil
                            }
                            .foregroundColor(.red)
                        } else {
                            /// It's a new host
                            Button("Save") {
                                let newHost = saveHost()
                                kodi.hosts.append(newHost)
                                saveAllHosts(hosts: kodi.hosts)
                                selectedHost = newHost
                            }
                        }
                    }
                }
            }
            .modifier(ViewKodiEditModifier())
            .padding()
        }
        .onChange(of: selectedHost, perform: { host in
            loadHost(host: selectedHost ?? HostFields())
        })
        .onAppear {
            loadHost(host: selectedHost ?? HostFields())
        }
        
    }
    func loadHost(host: HostFields) {
        description = host.description
        ip = host.ip
        port = host.port
        tcp = host.tcp
        username = host.username
        password = host.password
        selected = host.selected
    }
    func saveHost() -> HostFields {
        return HostFields(description: description,
                          ip: ip,
                          port: port,
                          tcp: tcp,
                          username: username,
                          password: username,
                          selected: selected)
    }
}

struct ViewKodiEditFooter: View {
    let text: String
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.bottom, 6)
    }
}

// MARK: - ViewKodiEditModifier (view modifier)

/// BorderlessButtonStyle() for iOS or else all buttons react at the same time
/// Also, stop that stupid correction behavior
struct ViewKodiEditModifier: ViewModifier {
    #if os(macOS)
    func body(content: Content) -> some View {
        content
            .disableAutocorrection(true)
    }
    #endif
    #if os(iOS)
    func body(content: Content) -> some View {
        content
            .buttonStyle(BorderlessButtonStyle())
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
    #endif
}
