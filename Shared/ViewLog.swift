///
/// ViewLog.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: ViewLog (view)

struct ViewLog: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// Show or hide log
    @AppStorage("ShowLog") var showLog: Bool = false

    let date: Date
    let dateFormatter: DateFormatter
    var info: String {
        var text = ""
        if kodi.library.online {
            text = "\(kodi.properties.info) @ \(kodi.selectedHost.ip)"
        }
        return text
    }

    init() {
        date = Date()
        dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(info)
                    .foregroundColor(.white)
                Spacer()
                Button("Hide Log") {
                    withAnimation {
                        showLog = false
                    }
                }
            }
            .font(.subheadline)
            .padding(4)
            .background(Color.black)
            ScrollView {
                ForEach(kodi.debugLog.reversed()) { debug in
                    HStack {
                        Text(debug.time, formatter: dateFormatter)
                        Text(debug.sender)
                            .font(.subheadline)
                        Text(debug.message)
                        Spacer()
                    }
                }
                .padding(.top, 4)
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color.green.opacity(0.2))
    }
}
