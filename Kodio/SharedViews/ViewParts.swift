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

struct ViewListHeader: View {
    let title: String
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

extension View {
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
        /// Arguments
        let type: Library.MediaType
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
        private func buttonSaturation(media: Library.MediaType) -> Double {
            switch media {
            case .albums:
                return 0.4
            case .artists:
                return 0.25
            case .genres:
                return 0.1
            default:
                return 1.0
            }
        }
    }
}

// MARK: - Rotating icon

/// View a rotating LP
struct ViewKodiRotatingIcon: View {
    /// State of the animation
    @Binding var animate: Bool
    /// The view
    var body: some View {
        Image("Record")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(Angle(degrees: self.animate ? 360 : 0.0))
            .animation(Animation.linear(duration: 3.6).repeat(while: animate), value: animate)
    }
}
