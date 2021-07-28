///
/// Radio.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

extension KodiClient {

    // MARK: - Play a Radio Station
    
    /// Clear the playlist
    /// Add a stream to the playlist
    /// Play the playlist
    
    func radio(stream: String) {
        /// # Don't bother with notifications
        self.notificate = false
        /// # Clear the playlist
        sendPlaylistAction(api: .playlistClear)
        /// # Add the stream and play it
        let request = PlaylistAction(method: .playlistAdd, stream: stream)
        sendRequest(request: request) { [weak self] result in
            switch result {
            case .success:
                /// # Update the playlist queue
                self?.updatePlaylistQueue()
                /// # Start notifications again
                self?.notificate = true
                /// # Start playing
                self?.sendPlayerAction(api: .playerOpen, playlistPosition: 0)
                /// # Empty the playlist queue
                self?.playlists.queue = []
            case .failure(let error):
                self?.log(#function, "Error: \(#function) \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: getRadioStations (function)

    /// Get the hardcoded list of radio stations
    /// - Returns: Struct of menu items

    func getRadioStations() -> [RadioFields] {
        var list = [RadioFields]()
        list.append(RadioFields(label: "Radio 1", stream: "https://icecast.omroep.nl/radio1-bb-aac"))
        list.append(RadioFields(label: "Radio 2", stream: "https://icecast.omroep.nl/radio2-bb-aac"))
        return list
    }
}

struct RadioFields: Identifiable, Hashable {
    var id = UUID()
    let label: String
    let stream: String
}
