///
/// Cache.swift
/// Kodio
///
/// © 2021 Nick Berendsen
///

import Foundation

/// Get and set structs to the cache directory
struct Cache {

    /// Get a struct from the cache
    /// - Parameters:
    ///   - key: The name of the item in the cache
    ///   - as: The struct to use for decoding
    ///   - root: Get it from the root folder; if false, it will get it from the Host IP folder
    /// - Returns: decoded cache item
    static func get<T: Codable>(key: String, as: T.Type, root: Bool = false) -> T? {
        let file = self.path(for: key, root: root)
        guard let data = try? Data(contentsOf: file) else {
            return nil
        }
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            logger("Can't decode '\(key)'")
            return nil
        }
        logger("Loaded '\(key)' from cache")
        return decoded
    }
    
    /// Save a struct into the cache
    /// - Parameters:
    ///   - key: The name for the item in the cache
    ///   - object:Tthe struct to save
    ///   - root: Store it in the root folder; if false, it will store it in the Host IP folder
    /// - Throws: an error if it can't be saved
    static func set<T: Codable>(key: String, object: T, root: Bool = false) throws {
        let file = self.path(for: key, root: root)
        let archivedValue = try JSONEncoder().encode(object)
        try archivedValue.write(to: file)
        logger("Stored '\(key)' in cache")
    }

    /// Get the path to the cache directory
    /// - Parameters:
    ///   - key: The name of the cache item
    ///   - root: Get the root path or the library host path
    /// - Returns: A full ``URL`` to the cache direcory
    static private func path(for key: String, root: Bool) -> URL {
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
