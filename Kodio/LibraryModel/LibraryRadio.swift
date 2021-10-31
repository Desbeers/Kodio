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
        var list = [RadioItem]()
        list.append(RadioItem(label: "Radio 1", thumbnail: "Radio1", stream: "https://icecast.omroep.nl/radio1-bb-aac"))
        list.append(RadioItem(label: "Radio 2", thumbnail: "Radio2", stream: "https://icecast.omroep.nl/radio2-bb-aac"))
        radioStations = list
    }
    
    /// The struct for a radio item
    struct RadioItem: Identifiable, Hashable {
        var id = UUID()
        let label: String
        let thumbnail: String
        let stream: String
    }
}
