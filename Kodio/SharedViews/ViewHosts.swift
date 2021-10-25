//
//  ViewHosts.swift
//  Kodio (shared)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - ViewHostsEdit (view)

/// A view to edit the list of Kodi hosts
struct ViewHostsEdit: View {
    /// The KodiClient model
    @EnvironmentObject var kodiClient: KodiClient
    /// The currently selected host
    @State var selectedHost = HostItem()
    @State var values = HostItem()
    @State var status: Status = .new
    /// The view
    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading) {
                    if !kodiClient.hosts.isEmpty {
                        Text("Your Kodi's")
                            .font(.headline)
                        ForEach(kodiClient.hosts) { host in
                            Button(
                                action: {
                                    selectedHost = host
                                    values = host
                                    status = host == kodiClient.selectedHost ? .selected : .edit
                                },
                                label: {
                                    Label(host.description, systemImage: host == kodiClient.selectedHost ? "k.circle.fill" : "k.circle")
//                                    HStack {
//                                        Image(systemName: host == kodiClient.selectedHost ? "k.circle.fill" : "k.circle")
//                                            .foregroundColor(.accentColor)
//                                            .frame(width: 16)
//                                        Text(host.description)
//                                        Spacer()
//                                    }
                                }
                            )
                                .disabled(host == selectedHost)
                        }
                    }
                    Text("New")
                        .font(.headline)
                    Button(
                        action: {
                            selectedHost = HostItem()
                            values = HostItem()
                            status = .new
                        },
                        label: {
                            Label("Add a new Kodi", systemImage: "plus")
                        }
                    )
                        .disabled(status == .new)
                    Spacer()
                }
                .sidebarButtons()
                .padding()
                .frame(maxWidth: 200)
            }
            .background(.thinMaterial)
            VStack {
                ViewHostsEditDetails(selectedHost: $selectedHost, values: $values, status: $status)
            }
            .padding()
            .frame(minWidth: 500)
        }
        .task {
            /// Select active host if we have one
            if !kodiClient.hosts.isEmpty {
                selectedHost = kodiClient.selectedHost
                values = kodiClient.selectedHost
                status = kodiClient.selectedHost.selected ? .selected : .edit
            }
        }
    }
}

extension  ViewHostsEdit {
    
    enum Status {
        case new
        case selected
        case edit
    }
    
    /// Edit the details of a Kodi hist
    struct ViewHostsEditDetails: View {
        /// The object that has it all
        @EnvironmentObject var kodiClient: KodiClient
        @Binding var selectedHost: HostItem
        @Binding var values: HostItem
        @Binding var status: Status
        /// The view
        var body: some View {
            VStack {
                Group {
                    switch status {
                    case .new:
                        Label("Add a new Kodi host", systemImage: "plus")
                    case .selected:
                        Label(selectedHost.description, systemImage: "k.circle.fill")
                    case .edit:
                        Label(selectedHost.description, systemImage: "k.circle")
                    }
                }
                .font(.title)
                Form {
                    Section(footer: ViewHostsEditFooter(text: "The name of your Kodi")) {
                        TextField("Name", text: $values.description)
                            .frame(width: 220)
                    }
                    Section(footer: ViewHostsEditFooter(text: "The ip address of your Kodi")) {
                        TextField("127.0.0.1", text: $values.ip)
                            .frame(width: 220)
                    }
                    Section(footer: ViewHostsEditFooter(text: "The TCP and UDP ports")) {
                        HStack(spacing: 10) {
                            TextField("8080", text: $values.port)
                                .frame(width: 100)
                            TextField("9090", text: $values.tcp)
                                .frame(width: 100)
                        }
                    }
                    Section(footer: ViewHostsEditFooter(text: "Your username and password")) {
                        HStack(spacing: 10) {
                            TextField("username", text: $values.username)
                                .frame(width: 100)
                            TextField("password", text: $values.password)
                                .frame(width: 100)
                        }
                    }
                }
                .modifier(ViewModifierForm())
                .padding()
                HStack {
                    Group {
                        switch status {
                        case .new:
                            addHost
                        case .selected:
                            updateHost
                        case .edit:
                            updateHost
                            selectHost
                            deleteHost
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        /// Add a host
        @ViewBuilder
        var addHost: some View {
            Button("Add") {
                logger("Add host")
                kodiClient.hosts.append(values)
                Hosts.save(hosts: kodiClient.hosts)
                selectedHost = values
                status = .edit
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!validateForm(host: values))
        }
        /// Update a host
        @ViewBuilder
        var updateHost: some View {
            Button("Update") {
                logger("Update host")
                if let index = kodiClient.hosts.firstIndex(of: selectedHost) {
                    kodiClient.hosts[index] = values
                    Hosts.save(hosts: kodiClient.hosts)
                    selectedHost = values
                    /// Reload if this host is selected
                    if status == .selected {
                        kodiClient.selectedHost = values
                    }
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!validateForm(host: values) || selectedHost == values)
        }
        /// Select a host
        @ViewBuilder
        var selectHost: some View {
            Button("Select") {
                logger("Select host")
                Hosts.selectHost(selected: selectedHost)
                status = .selected
            }
            .disabled(selectedHost != values)
        }
        /// Delete a host
        @ViewBuilder
        var deleteHost: some View {
            Button("Delete", role: .destructive) {
                logger("Delete host")
                if let index = kodiClient.hosts.firstIndex(of: selectedHost) {
                    KodiClient.shared.hosts.remove(at: index)
                    Hosts.save(hosts: kodiClient.hosts)
                    selectedHost = kodiClient.selectedHost
                    values = kodiClient.selectedHost
                    status = .selected
                }
            }
            .foregroundColor(.red)
        }
        /// Validate form
        private func validateForm(host: HostItem) -> Bool {
            var status = true
            if host.description.isEmpty {
                status = false
            }
            if !isValidIP(address: host.ip) {
                status = false
            }
            return status
        }
        /// Validate IP
        private func isValidIP(address: String) -> Bool {
            let parts = address.components(separatedBy: ".")
            let nums = parts.compactMap { Int($0) }
            return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
        }
    }
    
    /// The footer of a form section
    struct ViewHostsEditFooter: View {
        let text: String
        var body: some View {
            Text(text)
                .font(.caption)
                .padding(.bottom, 6)
        }
    }
    
    /// View modifier for host fields
    struct ViewModifierForm: ViewModifier {
#if os(macOS)
        func body(content: Content) -> some View {
            content
                .disableAutocorrection(true)
            /// Labels look terrible on macOS
                .labelsHidden()
        }
#endif
#if os(iOS)
        func body(content: Content) -> some View {
            content
                .disableAutocorrection(true)
                .autocapitalization(.none)
        }
#endif
    }
}

// MARK: - ViewKodiHostsMenu (view)

/// The Kodi host selector in a menu
struct ViewHostsMenu: View {
    /// The KodiClient model that has the hosts information
    @EnvironmentObject var kodiClient: KodiClient
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        if !kodiClient.selectedHost.ip.isEmpty {
            Button(
                action: {
                    appState.alertItem = appState.alertScanLibrary
                },
                label: {
                    Label("Reload \(kodiClient.selectedHost.description)", systemImage: "arrow.clockwise")
                }
            )
            Divider()
        }
        ForEach(kodiClient.hosts.filter { $0.selected == false }) { host in
            Button(
                action: {
                    Hosts.selectHost(selected: host)
                },
                label: {
                    Label(host.description, systemImage: "k.circle")
                }
            )
        }
    }
}
