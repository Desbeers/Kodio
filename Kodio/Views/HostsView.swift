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
    @EnvironmentObject var kodi: KodiConnector
    /// The selected host
    @State var selection: HostItem?
    /// The body of the `View`
    var body: some View {
        HStack {
            hostList
            #if os(macOS)
                .frame(width: 200)
            #endif
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
                ForEach(kodi.configuredHosts) { host in
                    hostItem(host: host)
                }
            }
            if !kodi.bonjourHosts.filter({ $0.new }).isEmpty {
                Section("New Kodi's on your network") {
                    ForEach(kodi.bonjourHosts.filter { $0.new }, id: \.ip) { host in
                        Label(title: {
                            Text(host.name)
                        }, icon: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                        })
                        .tag(HostItem(name: host.name, ip: host.ip, media: .audio, player: .local, status: .new))
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    /// The View for a Host
    /// - Parameter host: The Kodi `Host`
    /// - Returns: A View with the host information
    func hostItem(host: HostItem) -> some View {
        Label(title: {
            VStack(alignment: .leading) {
                Text(host.name)
                Text(host.isOnline ? "Online" : "Offline")
                    .font(.caption)
                    .opacity(0.6)
                    .padding(.bottom, 2)
            }
        }, icon: {
            Image(systemName: "globe")
                .foregroundColor(host.isOnline ? host.isSelected ? .green : .accentColor : .red)
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
