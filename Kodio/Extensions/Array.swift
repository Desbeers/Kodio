//
//  Duplicates.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import Foundation

extension Array where Element: Hashable {
    
    /// Remove duplicates in an `Array`
    /// - Returns: a filtered `Array`
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
}
