//
//  NSTableView.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

extension NSTableView {
    /// Remove the white background from Lists on macOS
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
        allowsColumnReordering = true
    }
}
