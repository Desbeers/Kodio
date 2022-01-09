//
//  ViewEditHosts.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// A view to edit the list of Kodi hosts
struct ViewEditHosts: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The currently selected host that we want to edit
    @State var selectedHost: HostItem?
    /// Struct for a new host
    let new = HostItem()
    /// The view
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Your Kodi's")) {
                    if !appState.hosts.isEmpty {
                        ForEach(appState.hosts, id: \.self) { host in
                            NavigationLink(destination: ViewForm(host: host,
                                                                 selection: $selectedHost,
                                                                 status: host.selected ? Status.selected : Status.edit),
                                           tag: host, selection: $selectedHost) {
                                HStack {
                                    Image(systemName: host.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 20, height: 20, alignment: .center)
                                    VStack(alignment: .leading) {
                                        Text(host.description)
                                        Text(host.ip)
                                            .font(.caption)
                                            .opacity(0.5)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                Section(header: Text("Add a new Kodi Host")) {
                    NavigationLink(destination: ViewForm(host: new,
                                                         selection: $selectedHost,
                                                         status: Status.new),
                                   tag: new, selection: $selectedHost) {
                        Label("New Kodi Host", systemImage: "plus")
                    }
                }
            }
            .animation(.default, value: appState.hosts)
            .navigationTitle("Kodi Hosts")
            Text("Add or edit your Kodi hosts")
        }
        /// Some extra love for macOS
        .macOS {$0
        .listStyle(.sidebar)
        .task {
            /// Select active host if we have one
            if !appState.hosts.isEmpty {
                selectedHost = appState.selectedHost
            }
        }
        }
    }
}

extension  ViewEditHosts {
    
    /// A form to edit a host
    struct ViewForm: View {
        /// The host we want to edit
        let host: HostItem
        /// The currently selected host; a Binding so we can alter the selection after adding a new host
        @Binding var selection: HostItem?
        /// The values of the form
        @State var values = HostItem()
        /// The status of the host currently editing
        @State var status: Status
        /// SF symbol picker
        @State private var isPresented = false
        /// The View
        var body: some View {
            Text(status == .new ? "Add a new Kodi Host" : "Edit \(host.description)")
                .font(.title)
            Form {
                Section(footer: footer(text: "The name of your Kodi")) {
                    TextField("Name", text: $values.description, prompt: Text("Name"))
                        .frame(width: 220)
                }
                Section(footer: footer(text: "The ip address of your Kodi")) {
                    TextField("127.0.0.1", text: $values.ip, prompt: Text("127.0.0.1"))
                        .frame(width: 220)
                }
                Section(footer: footer(text: "The TCP and UDP ports")) {
                    HStack(spacing: 10) {
                        TextField("8080", text: $values.port, prompt: Text("8080"))
                            .frame(width: 105)
#if os(iOS)
                        Divider()
#endif
                        TextField("9090", text: $values.tcp, prompt: Text("9090"))
                            .frame(width: 105)
                    }
                }
                Section(footer: footer(text: "Your username and password")) {
                    HStack(spacing: 10) {
                        TextField("username", text: $values.username, prompt: Text("kodi"))
                            .frame(width: 105)
#if os(iOS)
                        Divider()
#endif
                        TextField("password", text: $values.password, prompt: Text("kodi"))
                            .frame(width: 105)
                    }
                }
                Section(footer: footer(text: "Select an icon for your Kodi Host")) {
                    HStack {
                        Button(action: {
                            withAnimation {
                                isPresented.toggle()
                            }
                        }, label: {
                            Image(systemName: values.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.accentColor)
                                .frame(width: 30, height: 30, alignment: .center)
                        })
                            .buttonStyle(.plain)
                    }
                    .labelsHidden()
                    ViewSymbolsPicker(isPresented: $isPresented, icon: $values.icon, category: "KodiHosts")
                        .frame(width: 220)
                }
                Section {
                    HStack {
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
            .padding()
            .modifier(ViewModifierForm())
            .task {
                /// Fill the form
                values = host
            }
        }
        /// The text underneath a form item
        /// - Parameter text: The text to display
        /// - Returns: A ``Text`` view
        func footer(text: String) -> some View {
            Text(text)
                .font(.caption)
                .padding(.bottom, 6)
        }
        /// Add a host
        @ViewBuilder
        var addHost: some View {
            Button("Add") {
                logger("Add host")
                /// Give it a unique ID
                values.id = UUID()
                AppState.shared.hosts.append(values)
                Hosts.save(hosts: AppState.shared.hosts)
                /// Select it in the sidebar
                selection = values
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!validateForm(host: values))
        }
        /// Update a host
        @ViewBuilder
        var updateHost: some View {
            Button("Update") {
                logger("Update host")
                if let index = AppState.shared.hosts.firstIndex(of: host) {
                    AppState.shared.hosts[index] = values
                    Hosts.save(hosts: AppState.shared.hosts)
                    selection = values
                    /// Reload if this host is selected
                    if status == .selected {
                        AppState.shared.selectedHost = values
                    }
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!validateForm(host: values) || host == values)
        }
        /// Select a host
        @ViewBuilder
        var selectHost: some View {
            Button("Select") {
                logger("Select host")
                Hosts.selectHost(selected: host)
                values.selected = true
                selection = values
            }
            .disabled(host != values)
        }
        /// Delete a host
        @ViewBuilder
        var deleteHost: some View {
            Button("Delete", role: .destructive) {
                logger("Delete host")
                if let index = AppState.shared.hosts.firstIndex(of: host) {
                    AppState.shared.hosts.remove(at: index)
                    Hosts.save(hosts: AppState.shared.hosts)
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
    }
    /// The status of the host currently edited
    enum Status {
        /// The status cases of the host currently edited
        case new, selected, edit
    }
}
