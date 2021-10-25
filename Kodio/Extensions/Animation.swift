//
//  Animation.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = false) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}
