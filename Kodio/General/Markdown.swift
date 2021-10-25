/// - Note: https://github.com/NiftyTreeStudios/Nifty-Markdown-Formatter/

import SwiftUI

// MARK: Public
/**
 SwiftUI view with formatted markdown. The formatted markdown is wrapped in a `VStack` with no extra view modifiers.
 
 - Parameter markdown: The text needed to be formatted, as a `String`
 */
public struct FormattedMarkdown: View {
    public init(markdown: String) {
        self.markdown = markdown
    }
    let markdown: String
    
    public var body: some View {
        let formattedStrings = formattedMarkdownArray(markdown: markdown)
        VStack(alignment: .leading) {
            ForEach(0..<formattedStrings.count, id: \.self) { textView in
                formattedStrings[textView]
            }
        }
    }
}

/**
 Formats the markdown.
 - Parameter markdown: the markdown to be formatted as a `String`.
 
 - Returns: array of `Text` views.
 */
public func formattedMarkdownArray(markdown: String) -> [AnyView] {
    var formattedViews: [AnyView] = []
    let splitStrings: [String] = markdown.components(separatedBy: "\n")
    for string in splitStrings {
        if string.starts(with: "#") {
            let heading = formatHeading(convertMarkdownHeading(string))
            formattedViews.append(AnyView(heading))
        } else if string.starts(with: "    ") {
            formattedViews.append(
                AnyView(
                    HStack {
                        Text(string.trimmingCharacters(in: .whitespaces))
                            .multilineTextAlignment(.leading)
                            .font(.monospaced(.caption)())
                        
                    }
                        .padding(.leading)
                )
            )
        } else if string.starts(with: "- ") {
            formattedViews.append(
                AnyView(
                    HStack(alignment: .top) {
                        Text("・")
                        if let attributedString = try? AttributedString(markdown: string) {
                            Text(attributedString)
                        } else {
                            Text(string)
                        }
                    }
                        .padding(.bottom, 5)
                )
            )
        } else if string.range(of: "^[0-9].") != nil {
            // formattedViews.append(AnyView(Text(formatOrderedListItem(string))))
            formattedViews.append(
                formatOrderedListItem(string)
            )
        } else if string.isEmpty {
            // Ignore empty lines
            formattedViews.append(AnyView(Text(" ")))
        } else {
            if #available(iOS 15, macOS 12, *) {
                if let attributedString = try? AttributedString(markdown: string) {
                    formattedViews.append(AnyView(Text(attributedString)))
                } else {
                    formattedViews.append(AnyView(Text(string)))
                }
            } else {
                formattedViews.append(AnyView(Text(string)))
            }
        }
    }
    
    return formattedViews
}

// MARK: Private
// MARK: Headings
/// Heading struct used to represent headings.
internal struct Heading: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let headingSize: Int
}

/**
 Formats a markdown heading into a custom `Heading` struct.
 
 - Parameter string: the markdown string to be formatted.
 
 - Returns: a `Heading` with the correct heading size.
 */
internal func convertMarkdownHeading(_ string: String) -> Heading {
    let headingSize = string.distance(
        from: string.startIndex,
        to: string.firstIndex(of: " ") ?? string.startIndex
    )
    var headingText = string
    headingText.removeSubrange(
        headingText.startIndex...(
            headingText.firstIndex(of: " ") ?? headingText.startIndex
        )
    )
    return Heading(text: headingText, headingSize: headingSize)
}

/**
 Formats heading by giving it a correct font size.
 
 - Parameter heading: the heading to be formatted.
 
 - Returns: `Text` view with corrent font sizing.
 */
internal func formatHeading(_ formattedText: Heading) -> Text {
    if formattedText.headingSize <= 0 {
        return Text(formattedText.text).font(.body)
    } else if formattedText.headingSize == 1 {
        return Text(formattedText.text).font(.title2)
    } else if formattedText.headingSize == 2 {
        return Text(formattedText.text).font(.title3)
    } else if formattedText.headingSize == 3 {
        return Text(formattedText.text).font(.title2)
    } else if formattedText.headingSize == 4 {
        return Text(formattedText.text).font(.title3)
    } else if formattedText.headingSize == 4 {
        return Text(formattedText.text).font(.headline)
    } else if formattedText.headingSize >= 6 {
        return Text("    " + formattedText.text).font(.monospaced(.body)())
    } else {
        return Text(formattedText.text).font(.body)
    }
}

// MARK: Lists
/**
 Formats ordered lists.
 
 - Parameter string: the markdown string to be formatted into an ordered list item.
 
 - Returns: a `Text` view formatted into an ordered list item.
 */
internal func formatOrderedListItem(_ string: String) -> AnyView {
    let regex = "^[0-9*]."
    if string.range(of: regex, options: .regularExpression) != nil {
        var orderedItem = string
        var orderedPrefix = string
        orderedPrefix.removeSubrange(
            (orderedItem.firstIndex(of: " ") ?? orderedItem.startIndex)..<orderedItem.endIndex
        )
        //        orderedItem.replaceSubrange(
        //            orderedItem.startIndex...(
        //                orderedItem.firstIndex(of: ".") ?? orderedItem.startIndex
        //            ),
        //            with: "**\(orderedPrefix)**")
        orderedItem.removeSubrange(orderedItem.startIndex...(
            orderedItem.firstIndex(of: " ") ?? orderedItem.startIndex
        ))
        return AnyView(
            HStack {
                VStack(alignment: .leading) {
                    Text(orderedPrefix).bold().padding(.top, 9)
                    Spacer()
                }
                Text(orderedItem)
                    .multilineTextAlignment(.leading)
            }
        )
    } else {
        return AnyView(Text(string))
    }
}

/**
 Formats unordered lists.
 
 - Parameter string: the markdown string to be formatted into an unordered list item.
 
 - Returns: a `Text` view formatted into an ordered list item.
 */
internal func formatUnorderedListItem(_ string: String) -> String {
    if string.starts(with: "- ") {
        var orderedItem = string
        var orderedPrefix = string
        orderedPrefix.removeSubrange(
            (orderedItem.firstIndex(of: " ") ?? orderedItem.startIndex)..<orderedItem.endIndex
        )
        orderedItem.removeSubrange(orderedItem.startIndex...(
            orderedItem.firstIndex(of: " ") ?? orderedItem.startIndex
        ))
        return orderedItem
    } else {
        return string
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}
