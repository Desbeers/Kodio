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
        LinearGradient(gradient: Gradient(stops: [
            Gradient.Stop(color: Color.black.opacity(0.25), location: 0),
            Gradient.Stop(color: Color.black.opacity(0.025), location: 0.2),
            Gradient.Stop(color: Color.clear, location: 1)
        ]), startPoint: .bottom, endPoint: .top)
            .blendMode(.multiply)
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

/// Button style for a sidebar item
struct ButtonStyleSidebar: ButtonStyle {
    /// The style
    func makeBody(configuration: Configuration) -> some View {
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
                .padding(.horizontal, 4)
                .padding(.vertical, 6)
                .brightness(configuration.isPressed ? 0.2 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isEnabled ?  Color.clear : Color.secondary.opacity(0.2))
                .cornerRadius(6)
            /// A bit more padding for iOS
                .iOS {$0
                .padding(.horizontal, 6)
                }
        }
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .background(
                    VStack {
                        /// - Note: On iOS, the accentColor for a disabled button is grey, so, force blue
                        if AppState.shared.system == .macOS {
                            Color.accentColor
                        } else {
                            Color.blue
                        }
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
                .padding(.top)
            Image(systemName: item.icon)
                .resizable()
                .scaledToFit()
                .padding(40)
                .opacity(0.05)
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity)
        .id(item.empty)
        .transition(.move(edge: .trailing))
    }
}
