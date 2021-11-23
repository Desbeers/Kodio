///
/// Search.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation
import Combine

/// SearchObserver model
///
/// The only reason for this class is to keep the search a bit calm.
/// It will debounce the typing in the searchfield to an acceptable time.
/// The `query` is observed by a `view`, so I want to keep it away from any other observed classes
///
/// - Note: I tried to make this more `async` alike but found out this just works best
final class SearchObserver: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// Create a shared instance of the `SearchObserver` class
    static let shared = SearchObserver()
    /// The search query
    /// - Note: Used in a SwiftUI View
    @Published var query: String = ""
    /// The Combine container for the debouncing
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {
        $query
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { query in
                Task {
                    await Library.shared.searchLibrary(query: query)
                }
            })
            .store(in: &subscriptions)
    }
}
