//
//  Markdown.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// A view that returns a formatted Markdown string
struct FormattedMarkdown: View {
    /// The Markdown `String` that will be formatted
    let markdown: String
    /// The view
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

extension FormattedMarkdown {
    
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

extension FormattedMarkdown {
    
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
    @ViewBuilder func formatHeading(text: String, level: Int) -> some View {
        switch level {
        case 1:
            Text(text).font(.title2)
        case 2:
            Text(text).font(.title3)
        default:
            Text(text).font(.body)
        }
    }
}

// MARK: List items

extension FormattedMarkdown {
    
    /// Format a list item
    /// - Parameter text: the text of the list item
    /// - Returns: a formatted list item in an `HStack` view
    @ViewBuilder func formatListItem(text: String) -> some View {
        HStack(alignment: .top) {
            Text("・")
            formatAttributedString(text: text)
        }
        .padding(.bottom, 5)
    }
}

// MARK: Code blocks

extension FormattedMarkdown {
    
    /// Format a code block
    /// - Parameter text: the text of the code block
    /// - Returns: a formatted code block in an `HStack` view
    @ViewBuilder func formatCodeBlock(text: String) -> some View {
        HStack {
            Text(text.trimmingCharacters(in: .whitespaces))
                .multilineTextAlignment(.leading)
                .font(.monospaced(.caption)())
            
        }
        .padding(.leading)
    }
}

// MARK: Attributed string

extension FormattedMarkdown {
    
    /// Format a string if it has atributes
    /// - Parameter text: the Markdown text
    /// - Returns: the formatted text in a `Text` view
    @ViewBuilder func formatAttributedString(text: String) -> some View {
        if let attributedString = try? AttributedString(markdown: text) {
            Text(attributedString)
        } else {
            Text(text)
        }
    }
}
