//
//  SplitView.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import AppKit
import SwiftUI

// https://gist.github.com/HashNuke/f8895192fff1f275e66c30340f304d80

// MARK: - Horizontal split view (macOS)

/// The splitview controller
struct SplitView: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> NSViewController {
        let controller = SplitViewController()
        return controller
    }
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {
        // nothing here
    }
}

/// The splitview class
class SplitViewController: NSSplitViewController {
    private let splitViewResorationIdentifier = Bundle.main.bundleIdentifier! + ":mainSplitViewController"
    var vcTop = NSHostingController(rootView: ViewLibraryTop())
    var vcBottom = NSHostingController(rootView: ViewLibraryBottom())
    
    override func viewDidLoad() {
        splitView.isVertical = false
        splitView.dividerStyle = .thin
        splitView.autosaveName = NSSplitView.AutosaveName(splitViewResorationIdentifier)
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewResorationIdentifier)

        vcTop.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true
        vcBottom.view.heightAnchor.constraint(greaterThanOrEqualToConstant: 100).isActive = true

        let topItem = NSSplitViewItem(viewController: vcTop)
        topItem.canCollapse = false
        addSplitViewItem(topItem)

        let bottomItem = NSSplitViewItem(viewController: vcBottom)
        addSplitViewItem(bottomItem)
    }
}
