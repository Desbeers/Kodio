///
/// Search.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation
import Combine

/// SearchObserver model
class SearchObserver: ObservableObject {
    
    // MARK: Constants and Variables
    
    /// Create a shared instance
    static let shared = SearchObserver()
    /// The search string in the UI
    @Published var searchText = ""
    /// The search query
    @Published var query = ""
    /// Are we searching?
    var searchIsActive: Bool = false
    /// The Combine container
    private var subscriptions = Set<AnyCancellable>()
    
    // MARK: Init
    
    /// Private init to make sure we have only one instance
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
