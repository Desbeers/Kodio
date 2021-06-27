///
/// Debug.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - Debug related stuff (KodiClient extension)

extension KodiClient {

    // MARK: log (function)

    /// The log will only be 100 lines long and can be viewed with LogView()
    /// - Parameters:
    ///     - sender: String: function name (#function)
    ///     - message: String: the message

    func log( _ sender: String, _ message: String) {
        //print("\(sender): \(message)")
        DispatchQueue.main.async {
            if self.debugLog.count > 100 {
                self.debugLog = []
            }
            self.debugLog.append(DebugLog(time: Date(), sender: sender, message: message))
        }
    }
}

// MARK: - Debug log (struct)

/// The log entry fields
struct DebugLog: Identifiable {
    var id = UUID()
    var time: Date = Date()
    var sender: String = ""
    var message: String = ""
}

// MARK: - Debug JSON response (function)

/// Print raw JSON to the console
func debugJsonResponse(data: Data) {
    do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
            print(jsonResult)
        }
    } catch let error {
        print(error.localizedDescription)
    }
}
