///
/// WebSocket.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - WebSocket (Class)

/// The Delegate for the WebSocket connection
///
/// This will be called when connecting/disconnecting to the socket
class WebSocket: NSObject, URLSessionWebSocketDelegate {

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        KodiClient.shared.log(#function, "WebSocket connected")
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        KodiClient.shared.log(#function, "WebSocket disconnected")
    }
}

// MARK: - WebSocket related stuff (KodiClient extension)

extension KodiClient {
    
    // MARK: connectWebSocket (function)
    
    /// Connect to the Kodi WebSocket
    /// - Note:
    ///     On iOS, disconnect before going to the background or else Apple will be really upset.
    ///     I use `@Environment(\.scenePhase)` to keep an eye on that
    
    func connectWebSocket() {
        let url = URL(string: "ws://\(selectedHost.ip):\(selectedHost.tcp)/jsonrpc")!
        let webSocketDelegate = WebSocket()
        let session = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: OperationQueue())
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveNotification()
    }
    
    // MARK: disconnectWebSocket (function)
    
    /// Disconnect from the the Kodi WebSocket
    
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    // MARK: sendToWebSocket (function)
    
    /// Send a message to the websocket
    /// - Parameters:
    ///     - text: A prepared JSON string
    /// - Returns: An 'OK' notification to the websocket
    
    func sendToWebSocket(text: String) {
        webSocketTask?.send(.string(text)) { error in
            if let error = error {
                self.log(#function, "Error sending message \(error)")
            } else {
                self.log(#function, "Message sent to WebSocket")
            }
        }
    }
    
    // MARK: receiveNotification (function)
    
    /// Recieve a notification from the Kodi WebSocket
    /// - Note:
    ///     Notifications when sending a message to the WebSocket are ignored
    
    func receiveNotification() {
        webSocketTask?.receive { result in
            /// Call ourself again to receive the next notice
            if self.library.online {
                self.receiveNotification()
            }
            switch result {
            case .success(let message):
                if case .string(let text) = message, self.notificate {
                    /// get the notification
                    guard let data = text.data(using: .utf8),
                          let type = try? JSONDecoder().decode(DecodeNotification.self, from: data),
                          let method = NotificationMethod(rawValue: type.method)
                    else {
                        /// Not an interesting notification
                        self.log(#function, "Unknown message received")
                        print(message)
                        return
                    }
                    self.log(#function, type.method)
                    self.notificationAction(method: method)
                }
            case .failure:
                break
            }
        }
    }

    /// Do an action when we receive a notification from Kodi via the WbSocket
    /// - Parameter method: Emun; the received notification
    func notificationAction(method: NotificationMethod) {
        switch method {
        case .playerOnPlay:
            if self.playlists.queue.isEmpty {
                self.updatePlaylistQueue()
            }
            self.getPlayerProperties()
        case .playerOnStop:
            /// Give it a moment to settle
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.getPlayerProperties()
            }
        case .playerOnAVStart:
            self.getPlayerProperties()
        case .playlistOnClear:
            DispatchQueue.main.async {
                self.playlists.queue = []
            }
            self.updatePlaylistQueue()
        case .audioLibraryOnUpdate:
            self.getSmartLists()
        case .audioLibraryOnScanStarted:
            libraryIsScanning = true
        case .audioLibraryOnScanFinished:
            libraryIsScanning = false
            /// Check if we need to update our local cache
            getAudioLibraryLastUpdate()
        case .playerOnPropertyChanged:
            getPlayerProperties(playerItem: false)
            getPlaylistQueue()
        case .playerOnResume, .playerOnPause:
            getPlayerProperties(playerItem: false)
        }
    }
}

// MARK: - Notification (struct)

/// I'm only interested in the method
enum NotificationMethod: String {
    case playerOnPlay = "Player.OnPlay"
    case playerOnStop = "Player.OnStop"
    case playerOnPropertyChanged = "Player.OnPropertyChanged"
    case playerOnResume = "Player.OnResume"
    case playerOnPause = "Player.OnPause"
    case playerOnAVStart = "Player.OnAVStart"
    case playlistOnClear = "Playlist.OnClear"
    case audioLibraryOnUpdate = "AudioLibrary.OnUpdate"
    case audioLibraryOnScanStarted = "AudioLibrary.OnScanStarted"
    case audioLibraryOnScanFinished = "AudioLibrary.OnScanFinished"
}

// MARK: - Decode Notification (struct)

/// I'm only interested in the method
struct DecodeNotification: Decodable {
    var method: String
}
