//
//  NSTableView.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// Remove the white background from Lists
extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
    }
}
