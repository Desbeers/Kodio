//
//  LibraryRadio.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation
import SwiftUI

extension Library {

    // MARK: Radio stations
    
    /// Set the (currently hardcoded) list of radio stations
    func getRadioStations() {
        /// The list of radio stations
        var list = [RadioItem]()
        list.append(RadioItem(title: "NPO Radio 1",
                              icon: "1.square.fill",
                              color: .blue,
                              stream: "https://icecast.omroep.nl/radio1-bb-aac"
                             ))
        list.append(RadioItem(title: "NPO Radio 2",
                              icon: "2.square.fill",
                              color: .red,
                              stream: "https://icecast.omroep.nl/radio2-bb-aac"
                             ))
        list.append(RadioItem(title: "NPO Radio 5",
                              icon: "5.square.fill",
                              color: .orange,
                              stream: "https://icecast.omroep.nl/radio5-bb-aac"
                             ))
        list.append(RadioItem(title: "Omroep Zeeland",
                              icon: "z.square.fill",
                              color: .blue,
                              stream: "https://d3isaxd2t6q8zm.cloudfront.net/icecast/omroepzeeland/omroepzeeland_radio"
                             ))
        list.append(RadioItem(title: "Go-FM",
                              icon: "g.square.fill",
                              color: .cyan,
                              stream: "http://cc3b.beheerstream.com:8076/stream"
                             ))
        radioStations = list
    }

    /// The struct for a radio item
    struct RadioItem: Identifiable, Hashable {
        /// Make it indentifiable
        var id = UUID()
        /// The title for the radio station
        let title: String
        /// The SF symbol for the radio station
        let icon: String
        /// The color for the radio station
        let color: Color
        /// The stream URL for the radio station
        let stream: String
    }
}
