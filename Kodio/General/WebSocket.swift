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
        Task {
            await KodiClient.shared.ping()
            await appState.setState(current: appState.state == .wakeup ? .loadedLibrary : .connectedToHost)
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
        if let error = didCompleteWithError {
            logger("Network error: \(error.localizedDescription)")
            let appState: AppState = .shared
            Task {
                await appState.setState(current: .failure)
            }
        }
    }
}

extension KodiClient {
    
    // MARK: - WebSocket related stuff
    
    /// Connect to the Kodi host
    /// - Parameter host: an ``HostItem``
    func connectToHost(host: HostItem) async {
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
        /// Recieve notifications
        receiveNotification()
    }
    
    /// Disconnect from the the Kodi WebSocket
    func disconnectWebSocket() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
    }
    
    /// Check if Kodi is still alive
    /// - Note: Failure will be handled by the delegate
    func ping() async {
        webSocketTask?.send(.string("ping")) { error in
        if let error = error {
            print("Error pinging host \(error.localizedDescription)")
        } else {
            Task {
                await Task.sleep(5_000_000_000)
                await self.ping()
            }
        }
      }
    }
    
    /// Recieve a notification from the Kodi WebSocket
    func receiveNotification() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    /// get the notification
                    guard let data = text.data(using: .utf8),
                          let notification = try? JSONDecoder().decode(NotificationItem.self, from: data),
                          let method = Method(rawValue: notification.method)
                    else {
                        /// Not an interesting notification
                        /// Call ourself again to receive the next notification
                        self.receiveNotification()
                        return
                    }
                    logger("Notification: \(notification.method)")
                    self.notificationAction(method: method)
                }
                /// Call ourself again to receive the next notification
                self.receiveNotification()
            case .failure:
                /// Failures are handled by the delegate
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
        case .playerOnPlay:
            Task {
                await Queue.shared.getItems()
                await Player.shared.getItem()
                await Player.shared.getProperties()
            }
        case .playerOnStop:
            Task {
                await Player.shared.getItem()
                await Player.shared.getProperties()
            }
        /// Reload library lists, but only if the host is not currently scanning
        case .audioLibraryOnUpdate:
            if !scanningLibrary {
                Task {
                    await Library.shared.getLibraryListItems()
                }
            } else {
                logger("Not updating the list items, Host is scanning")
            }
        case .playerOnSpeedChanged:
            Task {
                await Player.shared.getProperties()
            }
        case .audioLibraryOnScanStarted:
            scanningLibrary = true
            logger("Scanning library on the host")
            /// Tell the ApppState
            Task { @MainActor in
                AppState.shared.scanningLibrary = true
            }
        case .audioLibraryOnScanFinished:
            scanningLibrary = false
            logger("Finished scanning library on the host")
            /// Tell the ApppState
            Task { @MainActor in
                AppState.shared.scanningLibrary = false
            }
            Task {
                /// See if we are still up to date
                await Library.shared.getLastUpdate()
            }
        default:
            logger("No action after notification")
        }
    }
}
