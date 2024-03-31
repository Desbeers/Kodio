//
//  MarkdownView.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// SwiftUI `View` for a Markdown text
///
/// This View is used for  Help and is parsing the Documentation Catalog
///
/// - Note: The first heading is ignored; the Views have to show it themself
struct MarkdownView: View {
    /// The Help model
    @Environment(HelpModel.self) private var help
    /// The Markdown `String` that will be formatted
    let markdown: String
    /// The body of the `View`
    var body: some View {
        let markdownLines: [MarkdownLine] = convertMarkdown(string: markdown)
        VStack(alignment: .leading) {
            ForEach(markdownLines) { line in
                switch line.markdownType {
                case .heading(let heading):
                    formatHeading(text: line.text, level: heading)
                case .text:
                    formatAttributedString(text: line.text)
                case .listItem:
                    formatListItem(text: line.text)
                case .quote:
                    formatQuote(text: line.text)
                case .codeBlock:
                    formatCodeBlock(text: line.text)
                case .spacing:
                    Text(" ")
                }
            }
        }
    }
}

// MARK: Convert a Markdown string to an array

extension MarkdownView {

    /// The `struct` for a Markdown line
    struct MarkdownLine: Identifiable {
        /// ID for the struct
        let id = UUID()
        /// The Markdown text
        let text: String
        /// The type of Markdown
        var markdownType: MarkdownType
    }

    /// The `enum` for a Markdown type
    enum MarkdownType {
        /// Just text; not a block element
        case text
        /// A Markdown heading
        case heading(Int)
        /// A Markdowen list item
        case listItem
        /// A Markdown code block
        case codeBlock
        /// A Markdown quote
        case quote
        /// An empty line
        case spacing
    }

    /// Convert a Markdown string into an array of `MarkdownLine` structs
    /// - Parameter string: a markdown string
    /// - Returns: an array of `MarkdownLine` structs
    func convertMarkdown(string: String) -> [MarkdownLine] {
        var markdownLines: [MarkdownLine] = []
        let splitStrings: [String] = markdown.components(separatedBy: "\n")
        for string in splitStrings {
            if string.starts(with: "#") {
                /// Heading
                let heading = convertHeading(text: string)
                markdownLines.append(MarkdownLine(text: heading.text, markdownType: .heading(heading.level)))
            } else if string.starts(with: "    ") {
                /// Code block
                markdownLines.append(MarkdownLine(text: string, markdownType: .codeBlock))
            } else if string.starts(with: "- ") {
                /// List item
                markdownLines.append(MarkdownLine(text: string, markdownType: .listItem))
            } else if string.starts(with: "> ") {
                /// Quote item
                markdownLines.append(MarkdownLine(text: string, markdownType: .quote))
            } else if string.isEmpty {
                /// Paragraph spacing
                markdownLines.append(MarkdownLine(text: string, markdownType: .spacing))
            } else {
                /// Default
                markdownLines.append(MarkdownLine(text: string, markdownType: .text))
            }
        }
        return markdownLines
    }
}

// MARK: Headings

extension MarkdownView {

    /// Convert a Markdown heading into seperate components
    /// - Parameter text: a `String` with a Markdown heading
    /// - Returns: a stripped text and the level of the header
    func convertHeading(text: String) -> (text: String, level: Int) {
        let level = text.distance(
            from: text.startIndex,
            to: text.firstIndex(of: " ") ?? text.startIndex
        )
        var heading = text
        heading.removeSubrange(
            heading.startIndex...(
                heading.firstIndex(of: " ") ?? heading.startIndex
            )
        )
        return (heading, level)
    }

    /// Format a heading
    /// - Parameters:
    ///   - text: the text of the heading
    ///   - level: the level of the heading
    /// - Returns: the formatted heading in a `Text` view
    @ViewBuilder
    func formatHeading(text: String, level: Int) -> some View {
        switch level {
        case 1:
            Text(text)
                .font(.title)
                .padding(.bottom, 5)
            EmptyView()
        case 2:
            Text(text)
                .font(.title2)
                .padding(.bottom, 5)
        case 3:
            Text(text)
                .font(.title3)
                .padding(.bottom, 5)
        default:
            Text(text)
                .font(.body)
        }
    }
}

// MARK: List items

extension MarkdownView {

    /// Format a list item
    /// - Parameter text: the text of the list item
    /// - Returns: a formatted list item in an `HStack` view
    @ViewBuilder
    func formatListItem(text: String) -> some View {
        HStack(alignment: .top) {
            Text("・")
            formatAttributedString(text: text)
        }
    }
}

// MARK: Code blocks

extension MarkdownView {

    /// Format a code block
    /// - Parameter text: the text of the code block
    /// - Returns: a formatted code block in an `HStack` view
    @ViewBuilder
    func formatCodeBlock(text: String) -> some View {
        HStack {
            Text(text
                .trimmingCharacters(in: .whitespaces))
            .multilineTextAlignment(.leading)
            .font(.monospaced(.caption)())
        }
        .padding(.leading)
    }
}

// MARK: Attributed string

extension MarkdownView {

    /// Format a string if it has atributes
    /// - Parameter text: the Markdown text
    /// - Returns: the formatted text in a `Text` view
    @ViewBuilder
    func formatAttributedString(text: String) -> some View {
        if text.contains("<doc:") {
            help.doccLink(text: text)
        } else if let attributedString = try? AttributedString(markdown: text) {
            Text(attributedString)
        } else {
            Text(text)
        }
    }
}

// MARK: Quote

extension MarkdownView {

    /// Format a quote
    /// - Parameter text: the Markdown text
    /// - Returns: the formatted text in a `Text` view
    @ViewBuilder
    func formatQuote(text: String) -> some View {
        VStack {
            if let attributedString = try? AttributedString(markdown: text) {
                Text(attributedString)
            } else {
                Text(text)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(6)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}
