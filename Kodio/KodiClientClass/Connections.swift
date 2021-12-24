//
//  Connections.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiClient {
    
    // MARK: - Connection related stuff
    
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
        let appState: AppState = .shared
        let url = URL(string: "ws://\(appState.selectedHost.ip):\(appState.selectedHost.tcp)/jsonrpc")!
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
                try await Task.sleep(nanoseconds: 5_000_000_000)
                await self.ping()
            }
        }
      }
    }
}
