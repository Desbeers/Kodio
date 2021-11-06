//
//  SplitView.swift
//  Kodio (macOS)
//
//  © 2021 Nick Berendsen
//

import SwiftUI

/// A splitview
///
/// The SwiftUI ``HSplitView`` behaves strange and does not remember its position
/// so I fall back on AppKit for this.
/// 
/// - Note: See [this Gist on GitHub](https://gist.github.com/HashNuke/f8895192fff1f275e66c30340f304d80)
struct SplitView: NSViewControllerRepresentable {
    
    /// Make the splitview
    /// - Parameter context: The Context
    /// - Returns: A NSViewController
    func makeNSViewController(context: Context) -> NSViewController {
        let controller = SplitViewController()
        return controller
    }
    
    /// Update the controller
    /// - Note: Nothing to do here but required by the protocol
    /// - Parameters:
    ///   - nsViewController: An NSViewController
    ///   - context: The Context
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}

extension SplitView {
    
    /// The SplitView controller class
    class SplitViewController: NSSplitViewController {
        /// The identifier for the splitview
        private let splitViewResorationIdentifier = Bundle.main.bundleIdentifier! + ":mainSplitViewController"
        /// The top view
        var vcTop = NSHostingController(rootView: ViewLibraryTop())
        /// The bottom view
        var vcBottom = NSHostingController(rootView: ViewLibraryBottom())
        /// Make the splitview
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
}
