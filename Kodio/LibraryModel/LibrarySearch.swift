//
//  LibrarySearch.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation
import SwiftUI

extension Library {
    
    // MARK: Search
    
    /// A struct will all search related items
    struct Search {
        /// The shared search observer
        var observer = SearchObserver.shared
        /// The search suggestions
        var suggestions: [SearchSuggestionItem] = []
        /// The search query
        var query = ""
    }
    
    /// Search the library
    func searchLibrary() {
        if !search.query.isEmpty {
            smartLists.selected = Library.searchButton
            /// Reload lists
            smartReload()
        }
        /// Search is canceled
        if !search.observer.searchIsActive {
            /// If search is still selected in de sidebar; reset the selection
            if smartLists.selected.media == .search {
                /// Reset selection
                smartLists.selected = smartLists.all.first!
            }
            /// Remove the suggestions
            search.suggestions = []
            /// Reload UI to rove the search
            smartReload()
        }
        
    }
    
    // The search button
    static let searchButton = Library.SmartListItem(
        title: "Search",
        subtitle: "Your search results",
        icon: "magnifyingglass",
        media: .search
    )
    
    func makeSearchSuggestions() {
        
        var results: [SearchSuggestionItem] = []
        /// Only suggest when there is a query
        if !search.query.isEmpty {
            
            let smartSearchMatcher = SmartSearchMatcher(searchString: search.query)

            let artistList = artists.all.filter { artists in
                if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(artists.artist) {
                        return true
                    }
                return smartSearchMatcher.matches(artists.artist)
                }

            let songList = songs.all.filter { songs in
                    if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(songs.title) {
                        return true
                    }
                    return smartSearchMatcher.matches(songs.title)
            }
            let albumList = albums.all.filter { albums in
                    if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(albums.title) {
                        return true
                    }
                    return smartSearchMatcher.matches(albums.title)
                }
            
                for artist in artistList {
                    results.append(SearchSuggestionItem(title: artist.artist, subtitle: "Artist in your library", suggestion: artist.artist, thumbnail: artist.thumbnail))
                }
                    
            for album in albumList {
                results.append(SearchSuggestionItem(title: album.title, subtitle: "Album from \(album.artist.first!)", suggestion: "\(album.artist.first!) \(album.title)", thumbnail: album.thumbnail))
            }
            for song in songList {
                results.append(SearchSuggestionItem(title: song.title, subtitle: "Song by \(song.artist.first!)", suggestion: "\(song.artist.first!) \(song.album) \(song.title)", thumbnail: song.thumbnail))
            }
        }
        search.suggestions = results
    }
    
    struct SmartSearchMatcher {

        /// Creates a new instance for testing matches against `searchString`.
        public init(searchString: String) {
            // Split `searchString` into tokens by whitespace and sort them by decreasing length
            searchTokens = searchString.split(whereSeparator: { $0.isWhitespace }).sorted { $0.count > $1.count }
        }

        /// Check if `candidateString` matches `searchString`.
        func matches(_ candidateString: String) -> Bool {
            
            // If there are no search tokens, everything matches
            guard !searchTokens.isEmpty else {
                return true
            }

            // Split `candidateString` into tokens by whitespace
            var candidateStringTokens = candidateString.split(whereSeparator: { $0.isWhitespace })

            // Iterate over each search token
            for searchToken in searchTokens {
                // We haven't matched this search token yet
                var matchedSearchToken = false

                // Iterate over each candidate string token
                for (candidateStringTokenIndex, candidateStringToken) in candidateStringTokens.enumerated() {
                    // Does `candidateStringToken` start with `searchToken`?
                    if let range = candidateStringToken.range(of: searchToken, options: [.caseInsensitive, .diacriticInsensitive]),
                       range.lowerBound == candidateStringToken.startIndex {
                        matchedSearchToken = true

                        // Remove the candidateStringToken so we don't match it again against a different searchToken.
                        // Since we sorted the searchTokens by decreasing length, this ensures that searchTokens that
                        // are equal or prefixes of each other don't repeatedly match the same `candidateStringToken`.
                        // I.e. the longest matches are "consumed" so they don't match again. Thus "c c" does not match
                        // a string unless there are at least two words beginning with "c", and "b ba" will match
                        // "Bill Bailey" but not "Barry Took"
                        candidateStringTokens.remove(at: candidateStringTokenIndex)

                        // Check the next search string token
                        break
                    }
                }

                // If we failed to match `searchToken` against the candidate string tokens, there is no match
                guard matchedSearchToken else {
                    return false
                }
            }

            // If we match every `searchToken` against the candidate string tokens, `candidateString` is a match
            return true
        }

        private(set) var searchTokens: [String.SubSequence]
    }
    
    struct SearchSuggestionItem: Identifiable {
        var id = UUID()
        var title: String
        var subtitle: String = ""
        var suggestion: String
        var thumbnail: String
    }
}
