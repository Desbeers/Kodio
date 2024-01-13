//
//  HostsView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` for add, edit, delete or select Kodi hosts
struct HostsView: View {
    /// The KodiConnector model
    @Environment(KodiConnector.self) private var kodi
    /// The selected host
    @State private var selection: HostItem?
    /// The body of the `View`
    var body: some View {
        HStack {
            hostList
            hostEdit
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

// MARK: Host list items

extension HostsView {

    /// The lists of hosts
    var hostList: some View {
        List(selection: $selection) {
            Section("Your Hosts") {
                if kodi.configuredHosts.isEmpty {
                    Text("You have no host configured")
                } else {
                    ForEach(kodi.configuredHosts) { host in
                        hostItem(host: host)
                    }
                }
            }
            if let newHosts = kodi.getNewHosts() {
                Section("New Kodi's on your network") {
                    ForEach(newHosts) { host in
                        Label(title: {
                            Text(host.name)
                        }, icon: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                        })
                        .tag(
                            HostItem(
                                name: host.name,
                                ip: host.ip,
                                port: 8080,
                                tcpPort: host.tcpPort,
                                media: .audio,
                                player: .local,
                                status: .new
                            )
                        )
                    }
                }
            }
        }
        #if os(macOS)
        .frame(width: 200)
        .listStyle(.sidebar)
        #else
        .listStyle(.insetGrouped)
        .frame(width: 300)
        #endif
    }

    /// The View for a Host
    /// - Parameter host: The Kodi `Host`
    /// - Returns: A View with the host information
    func hostItem(host: HostItem) -> some View {
        Label(title: {
            VStack(alignment: .leading) {
                Text(host.name)
                Text(kodi.hostIsOnline(host) ? "Online" : "Offline")
                    .font(.caption)
                    .opacity(0.6)
                    .padding(.bottom, 2)
            }
        }, icon: {
            Image(systemName: "globe")
                .foregroundColor(kodi.hostIsOnline(host) ? kodi.hostIsSelected(host) ? .green : .accentColor : .red)
        })
        .tag(host)
    }
    /// View for editing a host
    var hostEdit: some View {
        VStack {
            if let selection {
                KodiHostItemView(host: selection) {
                    self.selection = nil
                }
            } else {
                Text("Add or edit your Kodi hosts")
                    .font(.title)
                KodiHostItemView.KodiSettings()
                    .padding()
                    .background(.thickMaterial)
                    .cornerRadius(10)
                    .padding(40)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
