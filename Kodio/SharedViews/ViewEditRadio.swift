//
//  ViewEditRadio.swift
//  Kodio
//
//  Created by Nick Berendsen on 08/01/2022.
//

import SwiftUI

/// A View to edit Radio Stations
struct ViewEditRadio: View {
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The currently selected host that we want to edit
    @State var selectedStation: RadioStationItem?
    /// The setting to show the radio channels or not
    @AppStorage("showRadio") var showRadio: Bool = true
    /// Struct for a new host
    let new = RadioStationItem()
    /// The view
    var body: some View {
        NavigationView {
            List(selection: $selectedStation) {
                Section(header: Text("Your Radio Stations")) {
                    if !appState.radioStations.isEmpty {
                        ForEach(appState.radioStations, id: \.self) { station in
                            NavigationLink(destination: ViewForm(station: station,
                                                                 selection: $selectedStation,
                                                                 status: station.title.isEmpty ? Status.new : Status.edit),
                                           tag: station,
                                           selection: $selectedStation) {
                                HStack {
                                    ViewRadioStationArt(station: station)
                                        .frame(width: 30, height: 30, alignment: .center)
                                    Text(station.title)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                Section(header: Text("Add a new Radio Station")) {
                    NavigationLink(destination: ViewForm(station: new,
                                                         selection: $selectedStation,
                                                         status: Status.new),
                                   tag: new,
                                   selection: $selectedStation) {
                        Label("New Radio Station", systemImage: "plus")
                    }
                }
                Section(header: Text("Options")) {
                    Toggle(isOn: $showRadio) {
                        Text("Show in the sidebar")
                    }
                    Button(
                        action: {
                            RadioStations.save(stations: [RadioStationItem]())
                            appState.radioStations = RadioStations.defaultRadioStations()
                        },
                        label: {
                            Text("Reset Radio Stations")
                        }
                    )
                }
            }
            .animation(.default, value: appState.radioStations)
            .navigationTitle("Radio Stations")
            Text("Add or edit your Radio Stations")
        }
        /// Some extra love for macOS
        .macOS {$0
        .listStyle(.sidebar)
        }
    }
}

extension  ViewEditRadio {
    
    /// A form to edit a host
    struct ViewForm: View {
        /// The station we want to edit
        let station: RadioStationItem
        /// The currently selected host; a Binding so we can alter the selection after adding a new radio station
        @Binding var selection: RadioStationItem?
        /// The values of the form
        @State var values = RadioStationItem()
        /// The value for the background color
        @State var bgColor = Color.primary
        /// The value for the foreground olor
        @State var fgColor = Color.primary
        /// The status of the host currently editing
        @State var status: Status
        /// SF symbol picker
        @State private var isPresented = false
        /// The View
        var body: some View {
            VStack {
                Text(status == .new ? "Add a new Radio Station" : "Edit \(station.title)")
                    .font(.title)
                Form {
                    Section(footer: footer(text: "The name of your Radio Station")) {
                        TextField("Name", text: $values.title, prompt: Text("Name"))
                    }
                    Section(footer: footer(text: "A description for your Radio Station")) {
                        TextField("Description", text: $values.description, prompt: Text("Description"))
                    }
                    Section(footer: footer(text: "The stream URL for the radio station")) {
                        TextField("Stream URL", text: $values.stream, prompt: Text("Stream URL"))
                    }
                    Section(footer: footer(text: "Create an icon for your Radio Station")) {
                        HStack {
                            Text("Background:")
                            ColorPicker("Background color", selection: $bgColor, supportsOpacity: false)
                                .onChange(of: bgColor) { color in
                                    values.bgColor = color.hexString
                                }
                            Text("Foreground:")
                            ColorPicker("Foreground color", selection: $fgColor, supportsOpacity: false)
                                .onChange(of: fgColor) { color in
                                    values.fgColor = color.hexString
                                }
                            Text("Icon:")
                            Button(action: {
                                withAnimation {
                                    isPresented.toggle()
                                }
                            }, label: {
                                ViewRadioStationArt(station: values)
                                    .frame(width: 50, height: 50, alignment: .center)
                                    .cornerRadius(4)
                            })
                                .buttonStyle(.plain)
                        }
                        .labelsHidden()
                        ViewSymbolsPicker(isPresented: $isPresented, icon: $values.icon, category: "RadioStations")
                    }
                    Section {
                        HStack {
                            switch status {
                            case .new:
                                addStation
                            case .edit:
                                updateStation
                                deleteStation
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .modifier(ViewModifierForm())
            }
            .padding()
            .task {
                /// Fill the form
                values = station
                bgColor = Color(hexString: station.bgColor)
                fgColor = Color(hexString: station.fgColor)
            }
        }
        /// The text underneath a form item
        /// - Parameter text: The text to display
        /// - Returns: A ``Text`` view
        func footer(text: String) -> some View {
            Text(text)
                .font(.caption)
                .padding(.bottom, 6)
        }
        /// Add a host
        @ViewBuilder
        var addStation: some View {
            Button("Add") {
                logger("Add station")
                /// Give it a unique ID
                values.id = UUID()
                AppState.shared.radioStations.append(values)
                RadioStations.save(stations: AppState.shared.radioStations)
                /// Select it in the sidebar
                selection = values
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!validateForm(station: values))
        }
        /// Update a host
        @ViewBuilder
        var updateStation: some View {
            Button("Update") {
                logger("Update station")
                if let index = AppState.shared.radioStations.firstIndex(of: station) {
                    AppState.shared.radioStations[index] = values
                    RadioStations.save(stations: AppState.shared.radioStations)
                    selection = values
                }
            }
            .keyboardShortcut(.defaultAction)
            .disabled(!validateForm(station: values) || station == values)
        }
        /// Delete a host
        @ViewBuilder
        var deleteStation: some View {
            Button("Delete", role: .destructive) {
                logger("Delete station")
                if let index = AppState.shared.radioStations.firstIndex(of: station) {
                    AppState.shared.radioStations.remove(at: index)
                    RadioStations.save(stations: AppState.shared.radioStations)
                }
            }
            .foregroundColor(.red)
        }
        /// Validate the form with the RadioStationItem
        /// - Parameter station: The ``RadioStationItem`` currenly editing
        /// - Returns: True or false
        private func validateForm(station: RadioStationItem) -> Bool {
            var status = true
            if station.title.isEmpty {
                status = false
            }
            if station.description.isEmpty {
                status = false
            }
            if station.stream.isEmpty {
                status = false
            }
            return status
        }
    }
    /// The status cases of the radio station currently edited
    enum Status {
        /// The status cases of the radio station currently edited
        case new, edit
    }
}
