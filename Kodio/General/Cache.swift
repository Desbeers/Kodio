///
/// Cache.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

struct Cache {

    // MARK: Cache

    /// Get a struct from the cache
    /// - Parameters:
    ///   - key: the name of the item in the cache
    ///   - as: the struct to use for decoding
    ///   - root: save it in the root folder; if false, it will save in the Host IP folder
    /// - Returns: decoded cache item
    static func get<T: Codable>(key: String, as: T.Type, root: Bool = false) -> T? {
        let file = self.cachePath(for: key, root: root)
        guard let data = try? Data(contentsOf: file) else {
            return nil
        }
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            logger("Can't decode '\(key)'")
            return nil
        }
        logger("'\(key)' loaded from cache")
        return decoded
    }
    
    /// Save a struct into the cache
    /// - Parameters:
    ///   - key: the name for the item in the cache
    ///   - object: the struct to save
    ///   - root: save it in the root folder; if false, it will save in the Host IP folder
    /// - Throws: an error if it can't be saved
    static func set<T: Codable>(key: String, object: T, root: Bool = false) throws {
        let file = self.cachePath(for: key, root: root)
        let archivedValue = try JSONEncoder().encode(object)
        try archivedValue.write(to: file)
        logger("'\(key)' stored in cache")
    }

    /// The path to the cache directory
    /// - Parameter key: the name of the cache item
    /// - Returns: the full URL to the path; including file name
    static private func cachePath(for key: String, root: Bool) -> URL {
        let manager = FileManager.default
        let rootFolderURL = manager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        var nestedFolderURL = rootFolderURL[0]
        if !root {
            nestedFolderURL = rootFolderURL[0].appendingPathComponent(KodiClient.shared.selectedHost.ip)
            if !manager.fileExists(atPath: nestedFolderURL.relativePath) {
                do {
                    try manager.createDirectory(
                        at: nestedFolderURL,
                        withIntermediateDirectories: false,
                        attributes: nil
                    )
                } catch {
                    logger("Error creating directory")
                }
            }
        }
        return nestedFolderURL.appendingPathComponent(key + ".cache")
    }
}
