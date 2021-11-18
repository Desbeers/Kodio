//
//  LibraryRadio.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {

    // MARK: Radio stations
    
    /// Set the (currently hardcoded) list of radio stations
    func getRadioStations() {
        /// The list of radio stations
        var list = [RadioItem]()
        list.append(RadioItem(title: "NPO Radio 1",
                              description: "Nieuws, sport en achtergronden",
                              thumbnail: "NPO-Radio-1",
                              stream: "https://icecast.omroep.nl/radio1-bb-aac"
                             ))
        list.append(RadioItem(title: "NPO Radio 2",
                              description: "Er is maar één NPO Radio 2",
                              thumbnail: "NPO-Radio-2",
                              stream: "https://icecast.omroep.nl/radio2-bb-aac"
                             ))
        list.append(RadioItem(title: "NPO Radio 5",
                              description: "Muziek uit de jaren 60, 70 en 80",
                              thumbnail: "NPO-Radio-5",
                              stream: "https://icecast.omroep.nl/radio5-bb-aac"
                             ))
        radioStations = list
    }
    
    /// The struct for a radio item
    struct RadioItem: Identifiable, Hashable {
        /// Make it indentifiable
        var id = UUID()
        /// The title for the radio station
        let title: String
        /// The description for the radio station
        let description: String
        /// The thumbnail for the radio station
        let thumbnail: String
        /// The stream URL for the radio station
        let stream: String
    }
}
