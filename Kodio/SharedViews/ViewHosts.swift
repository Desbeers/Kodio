//
//  ViewHosts.swift
//  Kodio (shared)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// A view to edit the list of Kodi hosts
struct ViewHostsEdit: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The currently selected host
    @State var selectedHost = HostItem()
    /// The values in the form
    @State var values = HostItem()
    /// The status of the host that is edited
    @State var status: Status = .new
    /// The setting to show the radio channels or not
    @AppStorage("showRadio") var showRadio: Bool = false
    /// The view
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading) {
                    if !appState.hosts.isEmpty {
                        Text("Your Kodi's")
                            .font(.headline)
                        ForEach(appState.hosts) { host in
                            Button(
                                action: {
                                    selectedHost = host
                                    values = host
                                    status = host == appState.selectedHost ? .selected : .edit
                                },
                                label: {
                                    Label(host.description, systemImage: host == appState.selectedHost ? "k.circle.fill" : "k.circle")
                                }
                            )
                                .disabled(host == selectedHost)
                        }
                    }
                    Text("New Kodi")
                        .font(.headline)
                    Button(
                        action: {
                            selectedHost = HostItem()
                            values = HostItem()
                            status = .new
                        },
                        label: {
                            Label("Add a host", systemImage: "plus")
                        }
                    )
                        .disabled(status == .new)
                    Text("Radio channels")
                        .font(.headline)
                    Toggle(isOn: $showRadio) {
                        Text("Show radio channels")
                    }
                    Text("They are currently hardcoded so the list is not editable.")
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.caption)
                }
                .buttonStyle(ButtonStyleSidebar())
                .padding()
                .frame(maxWidth: 200)
            }
            .background(.thinMaterial)
            VStack {
                ViewDetails(selectedHost: $selectedHost, values: $values, status: $status)
            }
            .padding()
            .frame(minWidth: 500)
        }
        .task {
            /// Select active host if we have one
            if !appState.hosts.isEmpty {
                selectedHost = appState.selectedHost
                values = appState.selectedHost
                status = appState.selectedHost.selected ? .selected : .edit
            }
        }
    }
}

extension  ViewHostsEdit {
    
    /// The status of the host currently edited
    enum Status {
        /// The status cases of the host currently edited
        case new, selected, edit
    }
    
    /// Edit the details of a Kodi hist
    struct ViewDetails: View {
        /// The host to edit
        @Binding var selectedHost: HostItem
        /// The values of the form
        @Binding var values: HostItem
        /// The status of the host currently editing
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
                    Section(footer: footer(text: "The name of your Kodi")) {
                        TextField("Name", text: $values.description)
                            .frame(width: 220)
                    }
                    Section(footer: footer(text: "The ip address of your Kodi")) {
                        TextField("127.0.0.1", text: $values.ip)
                            .frame(width: 220)
                    }
                    Section(footer: footer(text: "The TCP and UDP ports")) {
                        HStack(spacing: 10) {
                            TextField("8080", text: $values.port)
                                .frame(width: 100)
                            TextField("9090", text: $values.tcp)
                                .frame(width: 100)
                        }
                    }
                    Section(footer: footer(text: "Your username and password")) {
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
                AppState.shared.hosts.append(values)
                Hosts.save(hosts: AppState.shared.hosts)
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
                if let index = AppState.shared.hosts.firstIndex(of: selectedHost) {
                    AppState.shared.hosts[index] = values
                    Hosts.save(hosts: AppState.shared.hosts)
                    selectedHost = values
                    /// Reload if this host is selected
                    if status == .selected {
                        AppState.shared.selectedHost = values
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
                if let index = AppState.shared.hosts.firstIndex(of: selectedHost) {
                    AppState.shared.hosts.remove(at: index)
                    Hosts.save(hosts: AppState.shared.hosts)
                    selectedHost = AppState.shared.selectedHost
                    values = AppState.shared.selectedHost
                    status = .selected
                }
            }
            .foregroundColor(.red)
        }
        /// Validate the form with the HostItem
        /// - Parameter host: The ``HostItem`` currenly editing
        /// - Returns: True or false
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
        /// Validate the IP address in the form with the HostItem
        /// - Parameter address: The IP address
        /// - Returns: True or false
        private func isValidIP(address: String) -> Bool {
            let parts = address.components(separatedBy: ".")
            let nums = parts.compactMap { Int($0) }
            return parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
        }
        /// The text underneath a form item
        /// - Parameter text: The text to display
        /// - Returns: A ``Text`` view
        func footer(text: String) -> some View {
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
    /// The AppState model that has the hosts information
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        if !appState.selectedHost.ip.isEmpty {
            Button(
                action: {
                    AppState.shared.viewAlert(type: .scanLibrary)
                },
                label: {
                    Label("Reload \(appState.selectedHost.description)", systemImage: "arrow.clockwise")
                }
            )
            Divider()
        }
        ForEach(appState.hosts.filter { $0.selected == false }) { host in
            Button(
                action: {
                    Hosts.switchHost(selected: host)
                },
                label: {
                    Label(host.description, systemImage: "k.circle")
                }
            )
        }
    }
}
