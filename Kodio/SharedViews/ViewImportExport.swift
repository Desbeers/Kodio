//
//  ViewImportExport.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// A View for importing and exporting Kiodio items
struct ViewImportExport: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The Kodio document
    @State private var document: KodioDocument = KodioDocument(content: "Kodio!")
    /// Bool to show the import document picker
    @State private var isImporting: Bool = false
    /// Bool to show the import document picker
    @State private var isExporting: Bool = false
    /// The name for the document
    @State private var defaultName: String = ""
    /// The action after importing a file
    @State private var action: Actions = .none
    /// The status of import/eport
    @State private var statusBar: String = "Ready for action!"
    /// The View
    var body: some View {

            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                    }
                    .foregroundColor(.secondary.opacity(0.05))
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer()
                    Text(statusBar)
                        .padding()
                        Spacer()
                    }
                        .background(.ultraThickMaterial)
                        .frame(width: .infinity, height: .infinity, alignment: .center)
                }
                
                .frame(width: .infinity, height: .infinity, alignment: .center)
                VStack {
                    Text("Import and Export Kodio items")
                        .font(.title)
                    Button(
                        action: {
                            importRadioStations()
                        },
                        label: {
                            Text("Import Radio Stations")
                        })
                        .padding()
                    Button(
                        action: {
                            exportRadioStations()
                        },
                        label: {
                            Text("Export Radio Stations")
                        })
                        .padding()
                    Spacer()
                }
                .padding()
            }

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
    /// Export Radio Items
    func exportRadioStations() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        defaultName = "MyRadioStations"
        let data = try! encoder.encode(AppState.shared.radioStations)
        document.content = String(decoding: data, as: UTF8.self)
        isExporting = true
    }
    /// Import Radio Items
    func importRadioStations() {
        action = .radioStations
        isImporting = true
    }
    /// Add Radio Items after import
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
    /// The actions that happen in this View
    enum Actions {
        /// The cases
        case none, radioStations
    }
}
