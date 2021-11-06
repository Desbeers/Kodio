//
//  LibrarySearch.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Library {
    
    // MARK: Search
    
    /// A struct will all search related items
    struct Search {
        /// The shared search observer
        var observer = SearchObserver.shared
        /// The search results
        var results: [SongItem] = []
        /// The search suggestions
        var suggestions: [SearchSuggestionItem] = []
    }
    
    /// Search the library, create suggestion and view the result
    func searchLibrary() {
        if !query.isEmpty {
            Task {
                /// Get search results
                async let results = getSearchResults()
                /// Make a list of suggestions
                async let suggestions = makeSearchSuggestions()
                search.results = await results
                search.suggestions = await suggestions
                if let button = libraryLists.all.first(where: { $0.media == .search}) {
                    Library.shared.selectLibraryList(libraryList: button)
                }
            }
        }
        /// Search is canceled
        if !search.observer.searchIsActive {
            /// Remove the suggestions
            search.suggestions = []
        }
    }
    
    /// Get a list of songs matching the search query
    /// - Returns: An arry of song items
    private func getSearchResults() async -> [SongItem] {
        let smartSearchMatcher = SmartSearchMatcher(searchString: query)
        return songs.all.filter { songs in
                if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(songs.searchString) {
                    return true
                }
                return smartSearchMatcher.matches(songs.searchString)
            }
    }
    
    /// Make a list of search suggestions
    /// - Returns: An array of search suggestion items
    private func makeSearchSuggestions() async -> [SearchSuggestionItem] {
        var results: [SearchSuggestionItem] = []
        let smartSearchMatcher = SmartSearchMatcher(searchString: query)
        /// Artists
        let artistList = artists.all.filter { artists in
            if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(artists.artist) {
                return true
            }
            return smartSearchMatcher.matches(artists.artist)
        }
        for artist in artistList {
            results.append(SearchSuggestionItem(title: artist.artist, subtitle: "Artist in your library", suggestion: artist.artist, thumbnail: artist.thumbnail))
        }
        /// Albums
        let albumList = albums.all.filter { albums in
            if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(albums.title) {
                return true
            }
            return smartSearchMatcher.matches(albums.title)
        }
        for album in albumList {
            results.append(SearchSuggestionItem(title: album.title, subtitle: "Album from \(album.artist.first!)", suggestion: "\(album.artist.first!) \(album.title)", thumbnail: album.thumbnail))
        }
        /// Songs
        let songList = songs.all.filter { songs in
            if smartSearchMatcher.searchTokens.count == 1 && smartSearchMatcher.matches(songs.title) {
                return true
            }
            return smartSearchMatcher.matches(songs.title)
        }
        for song in songList {
            results.append(SearchSuggestionItem(title: song.title, subtitle: "Song by \(song.artist.first!)", suggestion: "\(song.artist.first!) \(song.album) \(song.title)", thumbnail: song.thumbnail))
        }
        return results
    }
    
    /// Do a smart search in the library
    /// - Note: Based on code from https://github.com/hacknicity/SmartSearchExample
    private struct SmartSearchMatcher {
        /// Creates a new instance for testing matches against `searchString`.
        public init(searchString: String) {
            /// Split `searchString` into tokens by whitespace and sort them by decreasing length
            searchTokens = searchString.split(whereSeparator: { $0.isWhitespace }).sorted { $0.count > $1.count }
        }
        /// Check if `candidateString` matches `searchString`.
        func matches(_ candidateString: String) -> Bool {
            /// If there are no search tokens, everything matches
            guard !searchTokens.isEmpty else {
                return true
            }
            /// Split `candidateString` into tokens by whitespace
            var candidateStringTokens = candidateString.split(whereSeparator: { $0.isWhitespace })
            /// Iterate over each search token
            for searchToken in searchTokens {
                /// We haven't matched this search token yet
                var matchedSearchToken = false
                /// Iterate over each candidate string token
                for (candidateStringTokenIndex, candidateStringToken) in candidateStringTokens.enumerated() {
                    /// Does `candidateStringToken` start with `searchToken`?
                    if let range = candidateStringToken.range(of: searchToken, options: [.caseInsensitive, .diacriticInsensitive]),
                       range.lowerBound == candidateStringToken.startIndex {
                        matchedSearchToken = true
                        /// Remove the candidateStringToken so we don't match it again against a different searchToken.
                        candidateStringTokens.remove(at: candidateStringTokenIndex)
                        /// Check the next search string token
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
        /// The tokens to search for
        private(set) var searchTokens: [String.SubSequence]
    }
    
    /// The struct for a search suggestion item
    struct SearchSuggestionItem: Identifiable {
        /// Make it indentifiable
        var id = UUID()
        /// The title for the suggestion
        var title: String
        /// The subtitle for the suggestion
        var subtitle: String = ""
        /// The suggested search text
        var suggestion: String
        /// The thumbnail for the suggestion
        var thumbnail: String
    }
}
