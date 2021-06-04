//
//  ViewRadio.swift
//  Kodio
//
//  Created by Nick Berendsen on 03/06/2021.
//

import SwiftUI

// MARK: - ViewRadioMenu (view)

/// A view with a list of radio stations
struct ViewRadioMenu: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The smart lists
    static var radioStations = KodiClient.shared.getRadioStations()
    /// The view
    var body: some View {
        Menu("Radio stations") {
            ForEach(ViewRadioMenu.radioStations) { station in
                Button(station.label) {
                    kodi.radio(stream: station.stream)
                }
            }
        }
    }
}
