///
/// Cache.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

// MARK: - Cache related stuff (KodiClient extension)

extension KodiClient {

    // MARK: getCache (function)

    /// Get a struct from the cache
    /// - Parameters:
    ///   - key: the name of the item in the cache
    ///   - as: the struct to use for decoding
    /// - Returns: decoded cache item

    func getCache<T: Codable>(key: String, as: T.Type) -> T? {
        let file = self.cachePath(for: key)
        guard let data = try? Data(contentsOf: file) else {
            return nil
        }
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            log(#function, "Can't decode '\(key)'")
            return nil
        }
        log(#function, "'\(key)' loaded from cache")
        return decoded
    }

    // MARK: setCache (function)

    /// Save a struct into the cache
    /// - Parameters:
    ///   - key: the name for the item in the cache
    ///   - object: the struct to save
    /// - Throws: an error if it can't be saved

    func setCache<T: Codable>(key: String, object: T) throws {
        let file = self.cachePath(for: key)
        let archivedValue = try JSONEncoder().encode(object)
        try archivedValue.write(to: file)
        log(#function, "'\(key)' stored in cache")
    }

    // MARK: cachePath (function)

    /// The path to the cache directory
    /// - Parameter key: the name of the cache item
    /// - Returns: the full URL to the path; including file name

    private func cachePath(for key: String) -> URL {
        let manager = FileManager.default
        let rootFolderURL = manager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        let nestedFolderURL = rootFolderURL[0].appendingPathComponent(selectedHost.ip)
        if !manager.fileExists(atPath: nestedFolderURL.relativePath) {
            do {
                try manager.createDirectory(
                    at: nestedFolderURL,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            } catch {
                log(#function, "Error creating directory")
            }
        }
        return nestedFolderURL.appendingPathComponent(key + ".cache")
    }
}
