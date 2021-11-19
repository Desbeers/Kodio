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
        let appState: AppState = .shared
        logger("Kodio connected to \(appState.selectedHost.ip)")
        Task {
            await appState.kodiClient.ping()
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
        logger("WebSocket disconnected from \(AppState.shared.selectedHost.ip)")
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
