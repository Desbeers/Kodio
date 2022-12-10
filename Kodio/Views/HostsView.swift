//
//  HostsView.swift
//  Kodio
//
//  Created by Nick Berendsen on 09/08/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The View to add, edit, delete or select Kodi hosts
struct HostsView: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The selected host
    @State var selection: Host?
    /// The list of new Bonjour Kodi's
    @State var newBonjourHosts: [KodiConnector.BonjourHost] = []
    /// The host we want to edit
    /// - Note: can't use 'selection' because then the buttons will flash and thats ugly
    @State var edit = Host()
    /// The values of the form
    @State var values = Host()
    /// The help text; dynamic loaded
    @State var help: String = ""
    /// SF symbol picker
    @State private var showSymbolPicker = false
    /// The body of the `View`
    var body: some View {
        HStack {
            hostList
                .frame(width: 200)
            hostEdit
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .animation(.default, value: appState.hosts)
        .animation(.default, value: newBonjourHosts)
        .task(id: kodi.bonjourHosts) {
            findNewKodi()
        }
        .task(id: appState.hosts) {
            findNewKodi()
        }
        .task(id: selection) {
            /// Fill the form
            showSymbolPicker = false
            edit = selection ?? Host()
            values = edit
        }
        .task {
            help = HelpModel.getPage(help: .kodiSettings)
        }
    }

    /// Find new Kodi's
    func findNewKodi() {
        var list: [KodiConnector.BonjourHost] = []
        for host in kodi.bonjourHosts where appState.hosts.first(where: {$0.details.ip == host.ip}) == nil {
            list.append(host)
        }
        newBonjourHosts = list
    }
}

// MARK: Host list items

extension HostsView {

    /// The lists of hosts
    var hostList: some View {
        List(selection: $selection) {
            Section("Your Hosts") {
                ForEach(appState.hosts) { host in
                    hostItem(host: host)
                }
            }
            Section("Bonjour") {
                if newBonjourHosts.isEmpty {
                    Text("No new Kodi's found")
                        .font(.caption)
                } else {
                    ForEach(newBonjourHosts, id: \.name) {item in
                        /// Make a new Host
                        hostItem(host: Host(details: HostItem(ip: item.ip, media: .audio), icon: "bonjour", status: .new))
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    /// The View for a Host
    /// - Parameter host: The ``Host``
    /// - Returns: A View with the host information
    func hostItem(host: Host) -> some View {
        HStack {
            Image(systemName: host.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(host.color)
                .frame(width: 20, height: 20, alignment: .center)
            VStack(alignment: .leading) {
                Text(host.details.description)
                Text(host.details.ip)
                    .font(.caption)
                    .opacity(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .trailing) {
            Image(systemName: "star.fill")
                .opacity(host.status == .selected ? 0.8 : 0)
                .frame(width: 20, height: 20, alignment: .trailing)
        }
        .tag(host)
    }
    /// View for editing a host
    var hostEdit: some View {
        VStack {
            if let selection = selection {
                Label("\(selection.status == .new ? "Add" : "Edit") \(selection.details.description)", systemImage: selection.icon)
                    .font(.title)
                viewForm
            } else {
                    Text("Add or edit your Kodi hosts")
                        .font(.title)
                MarkdownView(markdown: help)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .padding(40)

            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

// MARK: Form Items

extension  HostsView {

    /// Form view to edit a host
    var viewForm: some View {
        Form {
            Grid(alignment: .center, verticalSpacing: 0) {
                GridRow {
                    label(text: "IP")
                    TextField("IP", text: $values.details.ip, prompt: Text("127.0.0.1"))
                        .frame(width: 220)
                        .gridCellColumns(3)
                        .gridCellAnchor(.leading)
                        .disabled(edit.details.isOnline)
                }
                validateIPLabel
                GridRow {
                    label(text: "Webserver")
                        .gridColumnAlignment(.trailing)
                    TextField("Webserver", text: $values.details.port, prompt: Text("8080"))
                        .frame(width: 105)
                        .gridColumnAlignment(.leading)
                    label(text: "TCP")
                        .gridColumnAlignment(.trailing)
                    TextField("TCP", text: $values.details.tcp, prompt: Text("9090"))
                        .frame(width: 105)
                        .gridColumnAlignment(.leading)
                }
                footer(text: "The WebServer and TCP ports")
                GridRow {
                    label(text: "Username")
                    TextField("Username", text: $values.details.username, prompt: Text("kodi"))
                        .frame(width: 105)
                    label(text: "Password")
                    TextField("Password", text: $values.details.password, prompt: Text("kodi"))
                        .frame(width: 105)
                }
                footer(text: "Your username and password")
                GridRow {
                    label(text: "Icon")
                    PartsView.SymbolsPicker(isPresented: $showSymbolPicker, icon: $values.icon, category: "KodiHosts")
                        .frame(width: 220)
                        .gridCellColumns(3)
                        .gridCellAnchor(.leading)
                }
                footer(text: "Select an icon for your Kodi host")
            }
            .gridCellUnsizedAxes(.vertical)
            HStack {
                switch values.status {
                case .new:
                    addHost
                case .selected:
                    updateHost
                case .configured:
                    updateHost
                    selectHost
                    deleteHost
                }
            }
            #if os(iOS)
            .buttonStyle(BorderlessButtonStyle())
            #endif
            if !edit.details.isOnline {
                Text("\(edit.details.description) is not online")
                    .font(.caption)
            }

        }
        .labelsHidden()
        .animation(.default, value: values)
    }

    /// The label for a form item
    /// - Parameter text: The text to display
    /// - Returns: A Text View
    func label(text: String) -> some View {
        Text("\(text):")
    }

    /// The text underneath a form item
    /// - Parameter text: The text to display
    /// - Returns: A Text View
    func footer(text: String, type: FooterType = .valid) -> some View {
        GridRow {
            Color.clear.gridCellUnsizedAxes([.horizontal, .vertical])
            Text(text)
                .font(.caption)
                .foregroundColor(type == .valid ? .primary : .red)
                .padding(.top, 5)
                .padding(.bottom)
                .gridCellColumns(3)
                .gridCellAnchor(.leading)
        }
    }
    /// The type of footer
    enum FooterType {
        /// The input is valid
        case valid
        /// The input is not correct
        case error
    }
}

// MARK: Buttons

extension HostsView {
    /// Add a host
    @ViewBuilder
    var addHost: some View {
        Button("Add") {
            logger("Add host")
            Task {
                /// Set as configured
                values.status = .configured
                /// Add it to the hosts
                appState.addHost(host: values)
                /// Select it in the sidebar
                selection = values
            }
        }
        .keyboardShortcut(.defaultAction)
        .disabled(!validateForm(host: values))
    }
    /// Update a host
    @ViewBuilder
    var updateHost: some View {
        Button("Update") {
            logger("Update host")
            Task {
                if let update = appState.updateHost(old: edit, new: values) {
                    selection = update
                }
            }
        }
        .disabled(!validateForm(host: values))
        .disabled(edit == values)
    }
    /// Select a host
    @ViewBuilder
    var selectHost: some View {
        Button("Select") {
            Task {
                logger("Select host")
                appState.selectHost(host: values)
                values.status = .selected
                selection = values
            }
        }
        .disabled(edit != values)
        .disabled(!values.details.isOnline)
    }
    /// Delete a host
    @ViewBuilder
    var deleteHost: some View {
        Button("Delete", role: .destructive) {
            Task {
                logger("Delete host")
                selection = nil
                appState.deleteHost(host: edit)
            }
        }
        .foregroundColor(.red)
    }
}

// MARK: Form validation

extension HostsView {

    /// Validate the form with the HostItem
    /// - Parameter host: The ``HostItem`` currenly editing
    /// - Returns: True or false
    private func validateForm(host: Host) -> Bool {
        /// The status of the form item
        var status = true
        if host.details.description.isEmpty {
            status = false
        }
        if !isValidIP() {
            status = false
        }
        return status
    }
    /// Validate the name label
    private var validateNameLabel: some View {
        let validate = isValidName()

        switch validate {
        case true:
            return footer(text: "The name of your Kodi")
        case false:
            return footer(text: "The name can't be empty", type: .error)
        }
    }
    /// Bool if the name is valid
    private func isValidName() -> Bool {
        return !values.details.description.isEmpty
    }
    /// Validate IP address
    private var validateIPLabel: some View {
        let validate = isValidIP()

        switch validate {
        case true:
            return footer(text: "The IP address of your Kodi")
        case false:
            if !isValidIPAvailable() {
                return footer(text: "This IP address is already configured", type: .error)
            } else {
                return footer(text: "This is not a valid IP address", type: .error)
            }
        }
    }

    /// Validate the IP address in the form with the HostItem
    /// - Parameter address: The IP address
    /// - Returns: True or false
    private func isValidIP() -> Bool {
        let parts = values.details.ip.components(separatedBy: ".")
        let nums = parts.compactMap { Int($0) }
        let validIP = parts.count == 4 && nums.count == 4 && nums.filter { $0 >= 0 && $0 < 256}.count == 4
        if validIP {
            return isValidIPAvailable()
        }
        return false
    }
    /// Bool if the IP is available
    private func isValidIPAvailable() -> Bool {
        if edit.details.ip != values.details.ip, appState.hosts.first(where: {$0.details.ip == values.details.ip}) != nil {
            return false
        }
        return true
    }
}
