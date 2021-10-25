///
/// Search.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation
import Combine

/// Library model
class SearchObserver: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// Create a shared instance
    static let shared = SearchObserver()
    /// The search string
    @Published var searchText = ""
    @Published var query = ""
    var searchIsActive: Bool = false
    /// Magic stuff
    private var subscriptions = Set<AnyCancellable>()
    private init() {
        $searchText
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink(receiveValue: { text in
                self.query = text
                if text.isEmpty {
                    self.searchIsActive = false
                }
                if !self.searchIsActive, !text.isEmpty {
                    /// Start the search
                    self.searchIsActive = true
                }
            })
            .store(in: &subscriptions)
    }
}
