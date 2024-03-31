//
//  HelpModel.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI

/// The model for ``HelpView``
@Observable
final class HelpModel {
    /// The page to show
    var page: Page? = .kodioHelp
    /// The content of the page
    var text: String = ""
}

extension HelpModel {

    /// The pages for the Help View
    enum Page: String, CaseIterable {
        /// General help
        case kodioHelp = "KodioHelp"
        /// Kodi Settings help
        case kodiSettings = "KodiSettings"
        /// Player Settings help
        case playerSettings = "PlayerSettings"
        /// Bugs help
        case bugs = "Bugs"
        /// The title of the help page
        var title: String {
            switch self {
            case .kodioHelp:
                "Kodio Help"
            case .kodiSettings:
                "Kodi Settings"
            case .playerSettings:
                "Player Settings"
            case .bugs:
                "Bugs, bugs, bugs!"
            }
        }
    }
}

extension HelpModel {

    /// Get the content of a help page
    /// - Parameter help: The page
    /// - Returns: The content of the page
    static func getPage(help: HelpModel.Page) -> String {
        if let filepath = Bundle.main.url(
            forResource: help.rawValue,
            withExtension: "md"
        ) {
            do {
                let contents = try String(contentsOf: filepath)
                return contents
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return ""
    }
}

extension HelpModel {

    /// Convert a 'docc' link to a SwiftUI `View` with a button
    /// - Parameter text: The text containing the link
    /// - Returns: A SwiftUI `View`
    @ViewBuilder
    func doccLink(text: String) -> some View {
        let doccRegex = /(?<leading>.+?)?<doc:(?<docc>.+?)>(?<trailing>.+?)?/
        if let result = text.wholeMatch(of: doccRegex) {
            HStack {
                if let leading = result.output.leading {
                    Text(leading)
                }
                if let page = Page(rawValue: result.output.docc.description) {
                    Button(action: {
                        self.page = page
                    }, label: {
                        Label(page.title, systemImage: "questionmark.circle.fill")
                    })
                        .buttonStyle(ButtonStyles.Help())
                }
                if let trailing = result.output.trailing {
                    Text(trailing)
                }
            }
        }
    }
}
