//
//  Notifications.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension KodiClient {
    
    // MARK: Notifications stuff

    /// Send a notification to the host
    /// - Note: The message will be received as a ``Method`` like 'Other.*message*'
    /// - Parameter message: The message to send
    func sendNotification(message: String) async {
        let message = SendNotification(notification: message)
        logger("Send notification: '\(message.method)'")
        do {
            _ = try await sendRequest(request: message)
        } catch {
            print(error)
        }
    }

    /// Recieve a notification from the Kodi WebSocket
    ///  - Note: Messages send by ourself are ignored
    func receiveNotification() {
        webSocketTask?.receive { result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    /// get the notification
                    guard let data = text.data(using: .utf8),
                          let notification = try? JSONDecoder().decode(NotificationItem.self, from: data),
                          let method = Method(rawValue: notification.method),
                          notification.params.sender != AppState.shared.kodioID
                    else {
                        /// Not an interesting notification
                        /// print(message)
                        /// Call ourself again to receive the next notification
                        self.receiveNotification()
                        return
                    }
                    logger("Notification: \(method.rawValue)")
                    self.notificationAction(notification: notification)
                }
                /// Call ourself again to receive the next notification
                self.receiveNotification()
            case .failure:
                /// Failures are handled by the delegate
                break
            }
        }
    }
    
    /// Do an action when we receive a notification from Kodi via the WebSocket
    /// - Parameters method: The received notification method
    func notificationAction(notification: NotificationItem) {
        let method = Method(rawValue: notification.method)
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
                    await Library.shared.getSongDetails(songID: notification.params.data?.itemID ?? 0)
                }
            }
        case .playerOnSpeedChanged:
            Task {
                await Player.shared.getProperties()
            }
        case .audioLibraryOnScanStarted:
            scanningLibrary = true
            logger("Scanning library on the host")
            /// Tell the AppState
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
        case .otherNewQueue:
            logger("New Queue send")
            Task {
                await Queue.shared.getItems()
            }
        default:
            logger("No action after notification")
        }
    }
    
    /// Send a notification to the host (Kodi API)
    struct SendNotification: KodiAPI {
        /// The message
        var notification: String
        /// Method
        let method = Method.notifyAll
        /// The JSON creator
        var parameters: Data {
            /// The parameters
            var params = Params()
            params.message = notification
            return buildParams(params: params)
        }
        /// The request struct
        struct Params: Encodable {
            /// Our identification so we don't respond to our own message
            let sender = AppState.shared.kodioID
            /// The message to send
            var message = ""
        }
        /// The response struct
        struct Response: Decodable { }
    }
    
    /// The notification item
    struct NotificationItem: Decodable {
        /// The method
        var method: String
        /// The params
        var params = Params()
        /// The params struct
        struct Params: Decodable {
            /// The optional data from the notice
            var data: DataItem?
            /// The sender of the notice
            var sender: String = ""
        }
        /// The struct for the notification data
        struct DataItem: Decodable {
            /// The item ID
            var itemID: Int?
            /// The type of item
            var type: String?
            /// Coding keys
            enum CodingKeys: String, CodingKey {
                /// The keys
                case type
                /// ID is a reserved word
                case itemID = "id"
            }
        }
    }
}
