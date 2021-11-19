//
//  LibraryQueue.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

/// The Queue class
///
/// This class takes care of:
/// - Getting the queue list from the host
/// - Clear the queue
/// - Add stuff to the queue
///
/// - Note: There are more 'actions' programmed than actualy used in Kodio
final class Queue {
    
    // MARK: Constants and Variables
    
    /// Create a shared instance
    static let shared = Queue()
    /// The shared client class
    let kodiClient = KodiClient.shared
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {}
}
