//
//  HelpModel.swift
//  Kodio
//
//  Created by Nick Berendsen on 16/08/2022.
//

import SwiftUI

/// The model for ``HelpView``
final class HelpModel: ObservableObject {
    /// The shared instance of this HelpModel class
    static let shared = HelpModel()
    /// The page to show
    @Published var page: Page? = .kodioHelp
    /// The content of the page
    @Published var text: String = ""
    /// Private init
    private init() { }
}

extension HelpModel {

    /// The pages for the Help View
    /// - Note: They are taken from the `Documentation Catalog`
    enum Page: String, CaseIterable {
        case kodioHelp = "KodioHelp"
        case kodiSettings = "KodiSettings"
        case replayGain = "ReplayGain"
        case bugs = "Bugs"
        var title: String {
            switch self {
            case .kodioHelp:
                return "Kodio Help"
            case .kodiSettings:
                return "Kodi Settings"
            case .replayGain:
                return "ReplayGain"
            case .bugs:
                return "Bugs, bugs, bugs!"
            }
        }
    }
}

extension HelpModel {
    
    /// Get the content of a help page
    /// - Parameter help: The page
    /// - Returns: The content of the page
    static func getPage(help: HelpModel.Page) -> String {
        if let filepath = Bundle.main.url(forResource: help.rawValue, withExtension: "md", subdirectory: "Documentation.docc") {
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
    
    /// Convert a 'docc' link to a SwiftUI View
    /// - Parameter text: The text containing the link
    /// - Returns: A SwiftUI View
    @ViewBuilder func doccLink(text: String) -> some View {
        // swiftlint:disable operator_usage_whitespace
        let doccRegex = /(?<leading>.+?)?<doc:(?<docc>.+?)>(?<trailing>.+?)?/
        // swiftlint:enable operator_usage_whitespace
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