///
/// AudioLibrary.swift
/// Kodio (macOS)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - Audio library related stuff (KodiClient extension)

extension KodiClient {
    
    // MARK: getAudioLibraryLastUpdate (function)
    
    /// Get the date/time of the last audio database update
    /// - Parameter cache: store in the local cache or not
    func getAudioLibraryLastUpdate(cache: Bool = false) {
        let request = AudioLibraryGetProperties()
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success(let result):
                guard let results = result?.result else {
                    return
                }
                /// Save if cache is true
                if cache {
                    do {
                        try self?.setCache(key: "LibraryLastUpdated", object: results)
                        self?.libraryUpToDate = true
                    } catch {
                        self?.log(#function, "Error saving LibraryLastUpdated")
                    }
                } else {
                    if let cache = self?.getCache(key: "LibraryLastUpdated", as: AudioLibraryProperties.self) {
                        if cache.libraryLastUpdated < results.libraryLastUpdated {
                            self?.libraryUpToDate = false
                            self?.log(#function, "Library is out of date.")
                            let alertItem = AppState.AlertItem(title: Text("Reload Library"),
                                                               message: Text("Your library is out of date.\nDo you want to reload it?"),
                                                               button: .default(Text("Reload"),
                                                                                action: {
                                                                                    /// Stop nagging after one time
                                                                                    DispatchQueue.main.async {
                                                                                        AppState.shared.alertItem = nil
                                                                                    }
                                                                                    self?.getLibrary(reload: true)
                                                                                }
                                                               )
                            )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                AppState.shared.alertItem = alertItem
                            }
                        }
                    }
                }
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: scanAudioLibrary (function)
    
    /// Tell Kodi to rescan the audio database
    /// - Parameter confirm: show an Alert to confirm this action
    func scanAudioLibrary(confirm: Bool = false) {
        if confirm {
            AppState.shared.alertItem = nil
            let request = SystemAction(api: .audioLibraryScan)
            sendMessage(request: request)
        } else {
            let alertItem = AppState.AlertItem(title: Text("Scan Library"),
                                               message: Text("Are you sure you want to scan the library?"),
                                               button: .default(Text("Scan"),
                                                                action: {
                                                                    self.scanAudioLibrary(confirm: true)
                                                                })
            )
            AppState.shared.alertItem = alertItem
        }
    }
}

// MARK: - AudioLibraryGetProperties (API request)

struct AudioLibraryGetProperties: KodiRequest {
    /// Arguments
    var api: KodiAPI = .audioLibraryGetProperties
    /// The JSON creator
    var parameters: Data {
        let method = api.method()
        return buildParams(method: method, params: Params())
    }
    /// The request struct
    struct Params: Encodable {
        let properties = ["librarylastupdated"]
    }
    /// The response struct
    typealias Response = AudioLibraryProperties
}

// MARK: - AudioLibraryProperties (struct)

/// The fields for the audio database
struct AudioLibraryProperties: Codable {
    var libraryLastUpdated: String = ""
}

extension AudioLibraryProperties {
    enum CodingKeys: String, CodingKey {
        case libraryLastUpdated = "librarylastupdated"
    }
}
