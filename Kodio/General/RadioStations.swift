//
//  RadioStations.swift
//  Kodio
//
//  Created by Nick Berendsen on 16/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The list of radio stations
var radioStations: [Audio.Details.Stream] {
    /// The list of radio stations
    var list = [Audio.Details.Stream]()
    list.append(Audio.Details.Stream(station: "NPO Radio 1",
                                     description: "Nieuws, sport en achtergronden",
                                     file: "https://icecast.omroep.nl/radio1-bb-aac"
                                    ))
    list.append(Audio.Details.Stream(station: "NPO Radio 2",
                                     description: "Er is maar één NPO Radio 2",
                                     file: "https://icecast.omroep.nl/radio2-bb-aac"
                                    ))
    list.append(Audio.Details.Stream(station: "NPO Radio 5",
                                     description: "Muziek uit de jaren 60, 70 en 80",
                                     file: "https://icecast.omroep.nl/radio5-bb-aac"
                                    ))
    list.append(Audio.Details.Stream(station: "Omroep Zeeland",
                                     description: "Onze Zeeeuwe zender!",
                                     file: "https://d3isaxd2t6q8zm.cloudfront.net/icecast/omroepzeeland/omroepzeeland_radio"
                                    ))
    list.append(Audio.Details.Stream(station: "GO-FM",
                                     description: "Muziek vanuit de overkant",
                                     file: "http://cc3b.beheerstream.com:8076/stream"
                                    ))
    return list
}
