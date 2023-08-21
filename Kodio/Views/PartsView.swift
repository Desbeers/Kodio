//
//  PartsView.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// SwiftUI `View` parts
enum PartsView {
    // Just a namespace here
}

extension PartsView {

    /// Header View for the Browser View
    struct BrowserHeader: View {
        /// The label of the header
        let label: String
        /// The optional index
        var index: String?
        /// The optional padding
        var padding: Double = 0
        /// The body of the `View`
        var body: some View {
            HStack {
                Text(label)
                if let index {
                    Text(index)
                        .bold()
                }
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .padding(.trailing, padding)
            .lineLimit(1)
            .minimumScaleFactor(0.1)
            .font(.subheadline)
        }
    }
}

extension PartsView {

    /// Header for a List View
    struct ListHeader: ViewModifier {
        func body(content: Content) -> some View {
            content
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RadialGradient(
                        gradient: Gradient(colors: [.accentColor, .black]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 280
                    )
                    .saturation(0.4)
                )
        }
    }
}

extension PartsView {

    /// The state of a View
    struct LoadingState: View {
        /// The message
        let message: String
        /// The SF symbol
        var icon: String?
        /// The body of the `View`
        var body: some View {
            VStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(.accentColor)
                } else {
                    ProgressView()
                }
                Text(message)
                    .padding()
            }
            .font(.title)
            .frame(maxHeight: .infinity)
        }
    }
}

extension PartsView {

    /// View a  record image that can rotate
    struct RotatingRecord: View {
        /// The RotatingAnimationModel
        @StateObject var rotateModel = RotatingRecordModel()
        /// The optional SF symbol
        var icon: String?
        /// The title
        var title: String? = ""
        /// The subtitle
        var subtitle: String
        /// The details
        var details: String
        /// Do we want to rotate or not
        @Binding var rotate: Bool
        /// The body of the `View`
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    Image("Record")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    VStack(spacing: 0) {
                        Group {
                            if let icon = icon {
                                Image(systemName: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Text(title ?? "Kodio")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(
                            width: minSize(size: geometry) / 5,
                            height: minSize(size: geometry) / 20,
                            alignment: .center
                        )
                        Spacer()
                        Text(subtitle)
                            .fontWeight(.semibold)
                            .frame(height: minSize(size: geometry) / 30, alignment: .center)
                        Text(details)
                            .fontWeight(.thin)
                            .opacity(0.8)
                            .frame(
                                width: minSize(size: geometry) / 5,
                                height: minSize(size: geometry) / 40,
                                alignment: .center
                            )
                    }
                    .font(.system(size: 100))
                    .lineLimit(1)
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.01)
                    .frame(width: minSize(size: geometry) / 4, height: minSize(size: geometry) / 4.8, alignment: .top)
                }
                .foregroundColor(.white)
                .shadow(radius: minSize(size: geometry) / 50)
                /// Below is needed or else the View will not center
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .center
                )

                /// The custom rotator
                .modifier(RotatingRecordModel.Rotate(rotate: rotateModel.rotating, status: $rotateModel.status))
            }
            .animation(.default, value: subtitle)
            .animation(
                rotateModel.rotating ? rotateModel.foreverAnimation : .linear(duration: 0), value: rotateModel.rotating
            )
            .task(id: rotate) {
                switch rotate {
                case true:
                    /// Start the rotation
                    /// - Note: It will start with some delay to make it more smoother
                    await rotateModel.startRotating()
                case false:
                    /// Tell the model we like to stop
                    /// - Note: It will be stopped when the animation is completed
                    rotateModel.stopRotating()
                }
            }
        }

        /// The minimum size of the record
        /// - Parameter size: The `View` size
        /// - Returns: The minimum size as `Double`
        func minSize(size: GeometryProxy) -> Double {
            return size.size.width > size.size.height ? size.size.height : size.size.width
        }
    }
}

extension PartsView {

    /// View a  tape image that can rotate
    struct RotatingTape: View {
        /// The RotatingAnimationModel
        @StateObject var rotateModel = RotatingRecordModel()
        /// The optional icon
        var icon: String?
        /// The title
        var title: String? = ""
        /// The subtitle
        var subtitle: String
        /// The details
        var details: String
        /// Do we want to rotate or not
        @Binding var rotate: Bool
        /// The body of the `View`
        var body: some View {
            GeometryReader { geometry in
                ZStack(alignment: .center) {
                    HStack(spacing: 0) {
                        Image("Left")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        /// The custom rotator
                        .modifier(RotatingRecordModel.Rotate(rotate: rotateModel.rotating, status: $rotateModel.status))
                        Image("Right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        /// The custom rotator
                        .modifier(RotatingRecordModel.Rotate(rotate: rotateModel.rotating, status: $rotateModel.status))
                    }
                    Image("Cover")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: minSize(size: geometry) / 50)
                    VStack(spacing: 2) {
                        Spacer()
                        Group {
                            if let icon = icon {
                                Image(systemName: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else {
                                Text(title ?? "Kodio")
                                    .fontWeight(.bold)
                            }
                        }
                        Text(subtitle)
                            .fontWeight(.semibold)
                        Text(details)
                            .fontWeight(.thin)
                            .opacity(0.8)
                    }
                    .font(.system(size: 100))
                    .lineLimit(1)
                    .foregroundColor(.black)
                    .shadow(radius: 0)
                    .minimumScaleFactor(0.01)
                    .frame(
                        width: minSize(size: geometry) / 3,
                        height: minSize(size: geometry) / 8 - 10,
                        alignment: .bottom
                    )
                }
                .padding()
                /// Below is needed or else the View will not center
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height,
                    alignment: .center
                )
            }
            .animation(.default, value: title)
            .animation(
                rotateModel.rotating ? rotateModel.foreverAnimation : .linear(duration: 0), value: rotateModel.rotating
            )
            .task(id: rotate) {
                switch rotate {
                case true:
                    /// Start the rotation
                    /// - Note: It will start with some delay to make it more smoother
                    await rotateModel.startRotating()
                case false:
                    /// Tell the model we like to stop
                    /// - Note: It will be stopped when the animation is completed
                    rotateModel.stopRotating()
                }
            }
        }

        /// The minimum size of the record
        /// - Parameter size: The `View` size
        /// - Returns: The minimum size as `Double`
        func minSize(size: GeometryProxy) -> Double {
            return size.size.width > size.size.height ? size.size.height : size.size.width
        }
    }
}

extension PartsView {

    /// View a Kodi host selector
    struct HostSelector: View {
        /// The AppState model that has the hosts information
        @EnvironmentObject var appState: AppState
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The body of the `View`
        var body: some View {
            if kodi.host.isOnline {
                Button(
                    action: {
                        Task {
                            appState.selection = .start
                            await kodi.loadLibrary(cache: false)
                        }
                    },
                    label: {
                        Label("Reload \(kodi.host.name)", systemImage: "arrow.clockwise")
                    }
                )
                Divider()
            }
            ForEach(kodi.configuredHosts) { host in
                Button(
                    action: {
                        appState.selection = .start
                        kodi.connect(host: host)
                    },
                    label: {
                        Label("\(host.name)\(host.isOnline ? "" : " (offline)")", systemImage: "globe")
                    }
                )
                .disabled(!host.isOnline || kodi.host == host)
            }
        }
    }
}

extension PartsView {

    /// View the song rating with stars
    /// - Parameters:
    ///   - rating: The rating
    /// - Returns: A view with stars
    static func ratings(rating: Int) -> some View {
        return HStack(spacing: 0) {
            ForEach(1..<6, id: \.self) { number in
                Image(systemName: image(number: number))
                    .font(.caption)
            }
        }

        /// Convert a number to an SF symbol image
        /// - Parameter number: The number
        /// - Returns: The String of the SF symbol
        func image(number: Int) -> String {
            if number * 2 <= rating {
                "star.fill"
            } else if number * 2 == rating + 1 {
                "star.leadinghalf.filled"
            } else {
                "star"
            }
        }
    }
}
