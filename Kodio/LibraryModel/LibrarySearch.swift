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
        /// The search results
        var results: [SongItem] = []
        /// The search suggestions
        var suggestions: [SearchSuggestionItem] = []
        /// The search query
        var query = ""
    }
    
    /// Search the library, create suggestion and view the result
    /// - Parameter query: The search query
    func searchLibrary(query: String) async {
        /// Save the query; some views need to know
        search.query = query
        /// Only search when there is a query
        if !query.isEmpty {
            /// Get search results
            async let results = getSearchResults(query: query)
            search.results = await results
            /// Make a list of suggestions
            search.suggestions = await getSearchSuggestions(query: query)
            /// Select 'Search' in the sidebar
            if let button = getLibraryLists().first(where: { $0.media == .search}) {
                await selectLibraryList(libraryList: button)
            }
        } else {
            /// Reset the search
            search = Search()
            /// Update the sidebar
            await AppState.shared.updateSidebar()
        }
    }

    /// Get a list of songs matching the search query
    /// - Parameter query: The search query
    /// - Returns: An array of `SongItem`s
    private func getSearchResults(query: String) async -> [SongItem] {
        logger("Search library")
        let searchMatcher = SearchMatcher(query: query)
        return songs.all.filter { songs in
                return searchMatcher.matches(songs.searchString)
            }
    }
    /// Get a list of search suggestions
    /// - Parameter query: The search query
    /// - Returns: An array of `SearchSuggestionItem`s
    private func getSearchSuggestions(query: String) async -> [SearchSuggestionItem] {
        logger("Make search suggestions")
        var results: [SearchSuggestionItem] = []
        let searchMatcher = SearchMatcher(query: query)
        /// Artists
        let artistList = artists.all.filter { artists in
            return searchMatcher.matches(artists.artist)
        }
        for artist in artistList {
            results.append(SearchSuggestionItem(title: artist.artist, subtitle: "Artist in your library", suggestion: artist.artist, icon: artist.icon))
        }
        /// Albums
        let albumList = albums.all.filter { albums in
            return searchMatcher.matches(albums.title)
        }
        for album in albumList {
            results.append(SearchSuggestionItem(title: album.title, subtitle: "Album from \(album.artist.first!)", suggestion: "\(album.artist.first!) \(album.title)", icon: album.icon))
        }
        /// Songs
        let songList = songs.all.filter { songs in
            return searchMatcher.matches(songs.title)
        }
        for song in songList {
            results.append(SearchSuggestionItem(title: song.title, subtitle: "Song by \(song.artist.first!)", suggestion: "\(song.artist.first!) \(song.album) \(song.title)", icon: song.icon))
        }
        return results
    }
    
    /// A struct for searching the library a bit smart
    /// - Note: Based on code from https://github.com/hacknicity/SmartSearchExample
    private struct SearchMatcher {
        /// Creates a new instance for testing matches against `query`.
        public init(query: String) {
            /// Split `query` into tokens by whitespace and sort them by decreasing length
            searchTokens = query.split(whereSeparator: { $0.isWhitespace }).sorted { $0.count > $1.count }
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
        var subtitle: String
        /// The suggested search text
        var suggestion: String
        /// The SF image for the suggestion
        var icon: String
    }
}
