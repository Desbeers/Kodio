///
/// ViewRadio.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

struct ViewRadioStations: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// Grid
    let colums = [
        GridItem(.adaptive(minimum: 200))
    ]
    /// The radio startions
    static var radioStations = KodiClient.shared.getRadioStations()
    /// The View
    var body: some View {
        VStack(alignment: .leading) {
            Text("Your radio stations")
                .font(.title)
                .padding(.top)
            Divider()
            LazyVGrid(columns: colums, alignment: .leading) {
                ForEach(ViewRadioMenu.radioStations) { station in
                    Button {
                        kodi.radio(stream: station.stream)
                    } label: {
                        HStack {
                            Label(station.label, systemImage: "antenna.radiowaves.left.and.right")
                            Spacer()
                        }
                    }
                }
            }
            .buttonStyle(ViewPlayerStyleButton())
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - ViewRadioMenu (view)

/// A view with a list of radio stations
struct ViewRadioMenu: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The radio startions
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
