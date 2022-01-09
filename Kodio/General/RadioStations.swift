//
//  RadioStations.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//
import Foundation

/// Radio stations related functions
struct RadioStations {
    
    /// Get a list of radio stations
    /// - Returns: An array of radio station items
    static func get() -> [RadioStationItem] {
        logger("Get the list of radio stations")
        if let stations = Cache.get(key: "MyRadioStations", as: [RadioStationItem].self, root: true),
           !stations.isEmpty {
            return stations
        } else {
            return self.defaultRadioStations()
        }
    }
    
    /// Save the radio station items to disk
    /// - Parameter stations: The array of radio station items
    static func save(stations: [RadioStationItem]) {
        do {
            try Cache.set(key: "MyRadioStations", object: stations, root: true)
        } catch {
            logger("Error saving MyRadioStations")
        }
    }
    
    /// Reorder the list of radio stations
    /// - Parameters:
    ///   - source: Move from
    ///   - destination: Move to
    @MainActor static func move(from source: IndexSet, to destination: Int) {
        let appState: AppState = .shared
        appState.radioStations.move(fromOffsets: source, toOffset: destination)
        RadioStations.save(stations: appState.radioStations)
    }
    
    /// Get a list of default radio stations
    /// - Returns: An array of ``RadioStationItem``s
    static func defaultRadioStations() -> [RadioStationItem] {
        /// The list of radio stations
        var list = [RadioStationItem]()
        list.append(RadioStationItem(title: "NPO Radio 1",
                                     description: "Nieuws, sport en achtergronden",
                                     icon: "1.square.fill",
                                     bgColor: "#003576",
                                     stream: "https://icecast.omroep.nl/radio1-bb-aac"
                                    ))
        list.append(RadioStationItem(title: "NPO Radio 2",
                                     description: "Er is maar één NPO Radio 2",
                                     icon: "2.square.fill",
                                     bgColor: "#d9151b",
                                     stream: "https://icecast.omroep.nl/radio2-bb-aac"
                                    ))
        list.append(RadioStationItem(title: "NPO Radio 5",
                                     description: "Muziek uit de jaren 60, 70 en 80",
                                     icon: "5.square.fill",
                                     bgColor: "#fab81d",
                                     stream: "https://icecast.omroep.nl/radio5-bb-aac"
                                    ))
        list.append(RadioStationItem(title: "Omroep Zeeland",
                                     description: "Onze Zeeeuwe zender!",
                                     icon: "z.square.fill",
                                     bgColor: "#00a0d2",
                                     stream: "https://d3isaxd2t6q8zm.cloudfront.net/icecast/omroepzeeland/omroepzeeland_radio"
                                    ))
        list.append(RadioStationItem(title: "GO-FM",
                                     description: "Muziek vanuit de overkant",
                                     icon: "g.square.fill",
                                     bgColor: "#0e9ba7",
                                     stream: "http://cc3b.beheerstream.com:8076/stream"
                                    ))
        return list
    }
}

/// The struct of a radio station item
struct RadioStationItem: Codable, Identifiable, Hashable {
    /// Make it indentifiable
    var id = UUID()
    /// The title for the radio station
    var title: String = ""
    /// The description for the radio station
    var description: String = ""
    /// The SF symbol for the radio station
    var icon: String = "exclamationmark.square.fill"
    /// The color for the radio station in hex
    var fgColor: String = "#FFFFFF"
    /// The color for the radio station in hex
    var bgColor: String = "#000000"
    /// The stream URL for the radio station
    var stream: String = ""
}
