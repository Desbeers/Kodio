//
//  ViewImportExport.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

struct ViewImportExport: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    @State private var document: KodioDocument = KodioDocument(content: "Kodio!")
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var defaultName: String = ""
    @State private var action: Actions = .none
    @State private var statusBar: String = ""
    
    var body: some View {
        VStack {
            Text("Import and Export Kodio items")
                .font(.title)
            Button(
                action: {
                    exportRadioStations()
                    
                },
                label: {
                    Text("Export Radio Stations")
                })
                .padding()
            Button(
                action: {
                    importRadioStations()
                    
                },
                label: {
                    Text("Import Radio Stations")
                })
                .padding()
            Spacer()
            Text(statusBar)
                .font(.caption)
        }
        .padding()
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .plainText,
            defaultFilename: defaultName
        ) { result in
            if case .success = result {
                statusBar = "Export was successfull"
            } else {
                // Handle failure.
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.plainText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else {
                    return
                }
                /// iOS sandbox stuff
                if selectedFile.startAccessingSecurityScopedResource() {
                    guard let content = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else {
                        return
                    }
                    switch action {
                    case .radioStations:
                        addRadioStations(stations: content)
                    default:
                        /// This should not happen
                        logger("Error")
                    }
                    selectedFile.stopAccessingSecurityScopedResource()
                }
            } catch {
                print("ERROR")
            }
        }
    }
    func exportRadioStations() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        defaultName = "MyRadioStations"
        let data = try! encoder.encode(AppState.shared.radioStations)
        document.content = String(decoding: data, as: UTF8.self)
        isExporting = true
    }
    func importRadioStations() {
        action = .radioStations
        isImporting = true
    }
    func addRadioStations(stations: String) {
        do {
            appState.radioStations = try JSONDecoder().decode([RadioStationItem].self, from: stations.data(using: .utf8)!)
            statusBar = "Imported Radio Stations"
            logger("Imported Radio Stations")
        } catch {
            statusBar = "Importing Radio Stations failed; it was not a valid file"
            print(error)
        }
    }
    /// The status cases of the radio station currently edited
    enum Actions {
        /// The status cases of the radio station currently edited
        case none, radioStations
    }
}
