//
//  NSSearchField.swift
//  Kodio
//
//  Created by Nick Berendsen on 18/11/2021.
//

import SwiftUI

extension NSSearchField {
    /// Hide the focus ring of the search field
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
