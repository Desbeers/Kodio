//
//  WebSocket.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

// MARK: - WebSocket (Class)

/// The Delegate for the WebSocket connection
///
/// This will be called when connecting/disconnecting to the socket
class WebSocket: NSObject, URLSessionWebSocketDelegate {
    /// Websocket notification when the connection starts
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        logger("Kodio connected to \(KodiClient.shared.selectedHost.ip)")
        
        let appState: AppState = .shared
        
        DispatchQueue.main.async {
            appState.state = appState.state == .wakeup ? .loadedLibrary : .connectedToHost
        }
    }
    /// Websocket notification when the connection stops
    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        logger("WebSocket disconnected from \(KodiClient.shared.selectedHost.ip)")
    }
    /// Websocket notification when the connection has an error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError: Error?) {
        let appState: AppState = .shared
        if appState.state != .sleeping {
            logger("WebSocket error from \(KodiClient.shared.selectedHost.ip)...")
            DispatchQueue.main.async {
                appState.state = .failure
                appState.alert = appState.alertNotAvailable
            }
        } else {
            logger("Disconnected...")
        }
    }
}

extension KodiClient {
    
    // MARK: - WebSocket related stuff
    
    /// Connect to the Kodi host
    /// - Parameter host: an ``HostItem``
    func connectToHost(host: HostItem) {
        AppState.shared.state = .none
        if !host.ip.isEmpty {
            logger("Connecting to Kodi on \(host.ip)")
            connectWebSocket()
        }
    }
    
    /// Connect the WebSocket
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
    
    /// Disconnect from the the Kodi WebSocket
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    /// Recieve a notification from the Kodi WebSocket
    /// - Note:
    ///     Notifications when sending a message to the WebSocket are ignored
    func receiveNotification() {
        webSocketTask?.receive { result in
            /// Call ourself again to receive the next notice
            self.receiveNotification()
            switch result {
            case .success(let message):
                if case .string(let text) = message, self.notificate {
                    /// get the notification
                    guard let data = text.data(using: .utf8),
                          let notification = try? JSONDecoder().decode(NotificationItem.self, from: data),
                          let method = Method(rawValue: notification.method)
                    else {
                        /// Not an interesting notification
                        return
                    }
                    logger("Notification: \(notification.method)")
                    self.notificationAction(method: method)
                }
            case .failure:
                break
            }
        }
    }

    /// The notification item
    /// - Note: - I'm only interested in the method
    struct NotificationItem: Decodable {
        /// The method
        var method: String
    }
    
    /// Do an action when we receive a notification from Kodi via the WebSocket
    /// - Parameters method: The received notification method
    func notificationAction(method: Method) {
        switch method {
        /// Set the slider in the UI
        case .applicationOnVolumeChanged:
            Task {
                await KodiHost.shared.getProperties()
            }
        /// Set the appropiate buttons in the UI (shuffle and repeat)
        case .playerOnPropertyChanged:
            Task {
                await Player.shared.getProperties()
            }
        /// Get the properties and current item of the player
        case .playerOnPlay, .playerOnStop:
            Task {
                await Queue.shared.getItems()
                await Player.shared.getItem()
                await Player.shared.getProperties()
            }
        /// Reload library lists
        case .audioLibraryOnUpdate:
            Task {
                await Library.shared.getLibraryListItems()
            }
        case .playerOnSpeedChanged:
            Task {
                await Player.shared.getProperties()
            }
        default:
            logger("No action after notification")
        }
    }
}
