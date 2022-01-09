//
//  Debug.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// Debug messages
func logger(_ string: String) {
    print("\(Thread.isMainThread ? "👀 " : "⺓ ")\(string) \(Date())")
}

/// Print raw JSON to the console
func debugJsonResponse(data: Data) {
    do {
        if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
            print(jsonResult)
        }
    } catch let error {
        print(error.localizedDescription)
    }
}
