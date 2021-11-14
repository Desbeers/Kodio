///
/// Search.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation
import Combine

/// SearchObserver model
final class SearchObserver: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// Create a shared instance
    static let shared = SearchObserver()
    /// The search query
    @Published var query: String = ""
    /// The Combine container
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
    private init() {
        $query
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { query in
                if Library.shared.query != query {
                    Library.shared.query = query
                }
            })
            .store(in: &subscriptions)
    }
}
