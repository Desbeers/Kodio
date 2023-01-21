//
//  StatusView.swift
//  Kodio
//
//  Created by Nick Berendsen on 27/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Status View; view the status of the KodiConnector
struct StatusView: View {
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    var body: some View {
        if kodi.state != .loadedLibrary {
            VStack {
                Spacer()
                VStack {
                    Text(kodi.state.message)
                        .font(.caption)
                    if kodi.state == .outdatedLibrary {
                        Button("Reload library") {
                            Task {
                                await kodi.loadLibrary(cache: false)
                            }
                        }
                        .padding(.bottom, 4)
                    }
                }
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity)
                .background(.ultraThickMaterial)
                .shadow(radius: 1)
            }
        }
    }
}
