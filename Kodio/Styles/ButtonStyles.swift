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
        /// The KodiPlayer model
        @EnvironmentObject var player: KodiPlayer
        /// The radio channe;
        let channel: Audio.Details.Stream
        /// The body of the `View`
        var body: some View {
            Button(action: {
                channel.play()
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
                    Image(systemName: radioIcon(channel: channel))
                        .foregroundColor(.purple)
                }
            })
        }

        /// The SF symbol for the radio item
        /// - Parameter channel: A `Stream` item
        /// - Returns: A 'String' with the name of the SF symbol
        func radioIcon(channel: Audio.Details.Stream) -> String {
            var icon = "antenna.radiowaves.left.and.right"
            if player.currentItem?.file == channel.file {
                if player.properties.speed == 0 {
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
        @Environment(\.isEnabled) var isEnabled
        /// The style
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .foregroundColor(isEnabled ? .primary : .secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color("Window").gradient)
                .cornerRadius(4)
                .shadow(radius: 1)
                .opacity(configuration.isPressed ? 0.8 : 1)
                .opacity(isEnabled ? 1 : 0.25)
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
                .background(Color("Window").gradient)
                .cornerRadius(4)
                .shadow(radius: 1)
                .opacity(configuration.isPressed ? 0.8 : 1)
        }
    }
}

extension ButtonStyles {

    /// Buttom style for a 'host action' button
    struct HostAction: ButtonStyle {
        /// Enabled or not
        @Environment(\.isEnabled) var isEnabled
        /// The style
        func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.gradient.opacity(0.2))
                .cornerRadius(4)
                .shadow(radius: 1)
                .opacity(configuration.isPressed ? 0.8 : 1)
                .opacity(isEnabled ? 1 : 0.25)
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
                        .brightness(selected ? 0 : buttonBrightness(item: item))
                        .saturation(selected ? 1 : buttonSaturation(item: item))
                )
                .cornerRadius(6)
                .brightness(configuration.isPressed ? 0.1 : 0)
                .padding(.vertical, 2)
                .padding(.trailing, 8)
        }

        /// Saturate a button
        /// - Parameter media: The media type
        /// - Returns: A saturation value
        private func buttonBrightness(item: any KodiItem) -> Double {
            switch item.media {
            case .album:
                return -0.3
            case .artist:
                return -0.2
            case .genre:
                return -0.1
            default:
                return 0.0
            }
        }

        /// Saturate a button
        /// - Parameter media: The media type
        /// - Returns: A saturation value
        private func buttonSaturation(item: any KodiItem) -> Double {
            switch item.media {
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
