//
//  ViewModifiers.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View bits and pieces

/// View a drop shadow
struct ViewDropShadow: View {
    var body: some View {
        VStack {
            Spacer()
            LinearGradient(gradient: Gradient(colors: [
                Color.black.opacity(0.25),
                Color.black.opacity(0.025),
                .clear]),
                           startPoint: .bottom, endPoint: .top)
                .frame(height: 200)
                .blendMode(.multiply)
        }
        .allowsHitTesting(false)
    }
}

/// View a header above a list
struct ViewListHeader: View {
    /// The title of the header
    let title: String
    /// The view
    var body: some View {
        Text(title)
            .font(.subheadline)
            .padding(.top, 4)
            .foregroundColor(Color.secondary)
    }
}

// MARK: - Style for an item in the sidebar

/// - Note: - This is a combination of Label and Button

/// Label style for a sidebar item
struct LabelStyleSidebar: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon.foregroundColor(.accentColor).frame(width: 24)
            configuration.title
            Spacer()
        }
    }
}

/// Button style for a sidebar item
struct ButtonStyleSidebar: ButtonStyle {
    /// The style
    func makeBody(configuration: Self.Configuration) -> some View {
        ViewButtonStyleSidebar(configuration: configuration)
    }
}

private extension ButtonStyleSidebar {
    
    /// The view for the button style in a list
    /// - Note: private extension becasue it is part of the 'ButtenStyleSidebar' ButtonStyle
    struct ViewButtonStyleSidebar: View {
        /// Tracks if the button is enabled or not
        @Environment(\.isEnabled) var isEnabled
        /// Tracks the pressed state
        let configuration: ButtonStyleSidebar.Configuration
        /// The view
        var body: some View {
            return configuration.label
                .padding(8)
            /// Smaller font for iOS
#if os(iOS)
                .font(.subheadline.weight(.regular))
#endif
                .brightness(configuration.isPressed ? 0.2 : 0)
                .background(isEnabled ?  Color.clear : Color.secondary.opacity(0.2))
                .cornerRadius(6)
        }
    }
}

/// Shortcut for the combined sidebar item style
struct SidebarButtons: ViewModifier {
    func body(content: Content) -> some View {
        content
            .labelStyle(LabelStyleSidebar())
            .buttonStyle(ButtonStyleSidebar())
    }
}

/// Extend View with a shortcut
extension View {
    /// Shortcut for sidebar buttons
    /// - Returns: A ``View`` modifier
    func sidebarButtons() -> some View {
        modifier(SidebarButtons())
    }
}

// MARK: - Style for a button in a list

/// Button style for a list item
struct ButtonStyleList: ButtonStyle {
    /// The media type of this button (genre, artist, album, playlist etc.)
    let type: Library.MediaType
    /// Bool if the button is selected or not
    let selected: Bool
    /// The style
    func makeBody(configuration: Self.Configuration) -> some View {
        ViewButtonStyleList(configuration: configuration, type: type, selected: selected)
    }
}

private extension ButtonStyleList {
    
    /// The view for the button style in a list
    /// - Note: private extension becasue it is part of the 'ButtenStyleList' ButtonStyle
    struct ViewButtonStyleList: View {
        /// Tracks the pressed state
        let configuration: ButtonStyleList.Configuration
        /// The type of the button
        let type: Library.MediaType
        /// Is the button selected or not?
        let selected: Bool
        /// The view
        var body: some View {
            return configuration.label
                .foregroundColor(.white)
                .background(
                    VStack {
                        Color.accentColor
                    }.saturation(selected ? 1 : buttonSaturation(media: type))
                )
                .cornerRadius(6)
                .brightness(configuration.isPressed ? 0.1 : 0)
                .padding(.vertical, 2)
                .padding(.trailing, 8)
        }
        
        /// Saturate a button
        /// - Parameter media: The media type
        /// - Returns: A saturation value
        private func buttonSaturation(media: Library.MediaType) -> Double {
            switch media {
            case .album:
                return 0.4
            case .artist:
                return 0.25
            case .genre:
                return 0.1
            default:
                return 1.0
            }
        }
    }
}

// MARK: - Rotating record

/// View a rotating record
struct ViewRotatingRecord: View {
    /// The animation
    var foreverAnimation: Animation {
        Animation.linear(duration: 3.6)
            .repeatForever(autoreverses: false)
    }
    /// The state of the animation
    @State var rotate: Bool = false
    /// The view
    var body: some View {
        Image("Record")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(Angle(degrees: self.rotate ? 360 : 0.0))
            .animation(rotate ? foreverAnimation : .easeInOut, value: rotate)
            .task {
                /// Give it a moment to settle; else the animation can be strange on macOS
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    rotate = true
                }
            }
    }
}

// MARK: - Empty library view

/// View to show when the current library view has no items to show
struct ViewEmptyLibrary: View {
    /// The current media item
    let item: LibraryItem
    /// The view
    var body: some View {
        VStack {
            Text(item.empty)
                .font(.title)
                .padding()
            Image(systemName: item.icon)
                .resizable()
                .scaledToFit()
                .padding()
                .opacity(0.1)
        }
        .frame(maxWidth: .infinity)
        .id(item.empty)
        .transition(.move(edge: .trailing))
    }
}
