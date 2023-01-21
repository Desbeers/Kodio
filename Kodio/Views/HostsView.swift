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
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The selected host
    @State var selection: HostItem?
    /// The body of the `View`
    var body: some View {
        HStack {
            hostList
                .frame(width: 200)
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
            if !kodi.bonjourHosts.filter({$0.new}).isEmpty {
                Section("New Kodi's on your network") {
                    ForEach(kodi.bonjourHosts.filter({$0.new}), id: \.ip) { host in
                        Label(title: {
                            Text(host.name)
                        }, icon: {
                            Image(systemName: "star.fill")
                                .foregroundColor(.orange)
                        })
                        .tag(HostItem(ip: host.ip, media: .audio, status: .new))
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    /// The View for a Host
    /// - Parameter host: The ``Host``
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
                .foregroundColor(host.isSelected ? host.isOnline ? .green : .red : .gray)
        })
        .tag(host)
    }
    /// View for editing a host
    var hostEdit: some View {
        VStack {
            if let selection {
                KodiHostItemView(host: selection)
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
