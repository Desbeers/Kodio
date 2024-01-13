//
//  ButtonStyles.swift
//  Macodi
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// The Button Styles for Kodio
enum ButtonStyles {
    // Just a namespace here
}

extension ButtonStyles {

    /// The Button View for a radio station
    struct RadioStation: View {
        /// The KodiConnector model
        @Environment(KodiConnector.self) private var kodi
        /// The radio channe;
        let channel: Audio.Details.Stream
        /// The body of the `View`
        var body: some View {
            Button(action: {
                channel.play(host: kodi.host)
            }, label: {
                Label {
                    VStack(alignment: .leading) {
                        Text(channel.station)
                            .lineLimit(nil)
                        Text(channel.description)
                            .lineLimit(nil)
                            .font(.caption)
                            .opacity(0.5)
                    }
                } icon: {
                    Image(systemName: radioIcon)
                        .foregroundColor(.purple)
                }
            })
        }
        /// The SF symbol for the radio item
        var radioIcon: String {
            var icon = "antenna.radiowaves.left.and.right"
            if kodi.player.currentItem?.file == channel.file {
                if kodi.player.properties.speed == 0 {
                    icon = "pause.fill"
                } else {
                    icon = "play.fill"
                }
            }
            return icon
        }
    }
}

extension ButtonStyles {

    /// Buttom style for a 'play', 'shuffle' or 'stream' button
    struct Play: ButtonStyle {
        /// Enabled or not
        @Environment(\.isEnabled)
        var isEnabled
        /// The style
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(.primary.opacity(0.8))
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
                .background(Color.secondaryAccent.gradient)
                .cornerRadius(6)
                .shadow(radius: 1)
                .opacity(configuration.isPressed ? 0.8 : 1)
                .opacity(isEnabled ? 1 : 0.5)
        }
    }
}

extension ButtonStyles {

    /// Buttom style for Music Video navigation
    struct MusicVideoNavigation: ButtonStyle {
        /// The style
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(.white)
                .font(.title2)
                .opacity(configuration.isPressed ? 0.6 : 0.8)
        }
    }
}

extension ButtonStyles {

    /// Buttom style for a 'help' button
    struct Help: ButtonStyle {
        /// The style
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(.primary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondaryAccent.gradient)
                .cornerRadius(4)
                .shadow(radius: 1)
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
    }
}

extension ButtonStyles {

    /// Button style for the browser
    struct Browser: ButtonStyle {
        /// The kodi item
        let item: any KodiItem
        /// Bool if selected or not
        let selected: Bool
        /// The style
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .background(
                    Color.accentColor
                        .brightness(selected ? 0 : buttonColor.brightness)
                        .saturation(selected ? 1 : buttonColor.saturation)
                )
                .cornerRadius(6)
                .brightness(configuration.isPressed ? 0.1 : 0)
                .padding(.vertical, 2)
                .padding(.trailing, 8)
#if os(visionOS)
                .hoverEffect()
#endif
        }
        /// Brightness and saturation values for a button
        private var buttonColor: (brightness: Double, saturation: Double) {
            switch item.media {
            case .album:
                (-0.3, 0.4)
            case .artist:
                (-0.2, 0.25)
            case .genre:
                (-0.1, 0.1)
            default:
                (0.0, 1.0)
            }
        }
    }
}

extension ButtonStyles {

    /// A `ViewModifier` to add a play button style
    struct PlayButtonStyle: ViewModifier {
        public func body(content: Content) -> some View {
            content
            #if os(visionOS)
                .buttonStyle(.bordered)
            #else
                .buttonStyle(Play())
            #endif
        }
    }
}

extension View {

    /// A `ViewModifier` to add a play button style
    func playButtonStyle() -> some View {
        modifier(ButtonStyles.PlayButtonStyle())
    }
}
