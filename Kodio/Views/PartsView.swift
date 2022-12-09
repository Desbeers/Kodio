//
//  PartsView.swift
//  Kodio
//
//  Created by Nick Berendsen on 16/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// Shared bits and pieces Views used in other Views
enum PartsView {
    /// Just a placeholder
}

extension PartsView {

    /// Header View for the Browser View
    struct BrowserHeader: View {
        let label: String
        var body: some View {
            Text(label)
                .font(.subheadline)
                .padding(.top, 4)
                .foregroundColor(Color.secondary)
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
                    RadialGradient(gradient: Gradient(colors: [.accentColor, .black]), center: .center, startRadius: 0, endRadius: 280)
                        .saturation(0.4)
                )
        }
    }
}

extension PartsView {

    /// The state of a View
    struct LoadingState: View {
        let message: String
        var icon: String?
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
        var icon: String?
        var title: String? = ""
        var subtitle: String
        var details: String
        /// Do we want to rotate or not
        @Binding var rotate: Bool
        /// The view
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
                        .frame(width: minSize(size: geometry) / 5, height: minSize(size: geometry) / 20, alignment: .center)
                        Spacer()
                        Text(subtitle)
                            .fontWeight(.semibold)
                            .frame(height: minSize(size: geometry) / 30, alignment: .center)
                        Text(details)
                            .fontWeight(.thin)
                            .opacity(0.8)
                            .frame(width: minSize(size: geometry) / 5, height: minSize(size: geometry) / 40, alignment: .center)
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
            .animation(rotateModel.rotating ? rotateModel.foreverAnimation : .linear(duration: 0), value: rotateModel.rotating)
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

        func minSize(size: GeometryProxy) -> CGFloat {
            return size.size.width > size.size.height ? size.size.height : size.size.width
        }
    }
}

extension PartsView {

    /// View a  tape image that can rotate
    struct RotatingTape: View {
        /// The RotatingAnimationModel
        @StateObject var rotateModel = RotatingRecordModel()
        var icon: String?
        var title: String? = ""
        var subtitle: String
        var details: String
        /// Do we want to rotate or not
        @Binding var rotate: Bool
        /// The view
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
                    VStack(spacing: 0) {
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
                    .frame(width: minSize(size: geometry) / 3, height: minSize(size: geometry) / 8, alignment: .bottom)
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
            .animation(rotateModel.rotating ? rotateModel.foreverAnimation : .linear(duration: 0), value: rotateModel.rotating)
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

        func minSize(size: GeometryProxy) -> CGFloat {
            return size.size.width > size.size.height ? size.size.height : size.size.width
        }
    }
}

extension PartsView {

    /// A View to select an SF symbol
    struct SymbolsPicker: View {
        /// Show this View or not
        @Binding var isPresented: Bool
        /// The selected icon
        @Binding var icon: String
        /// The category of SF symbols to show
        let category: String
        /// The View
        var body: some View {
            ScrollView(.horizontal) {
                HStack {
                    if isPresented {
                        ForEach(symbols[category]!, id: \.hash) { icon in
                            image(icon: icon)
                        }
                    } else {
                        image(icon: icon)
                    }
                }
            }
        }
        func image(icon: String) -> some View {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30, alignment: .center)
                .foregroundColor(self.icon == icon ? Color.accentColor : Color.primary)
                .onTapGesture {
                    withAnimation {
                        self.icon = icon
                        isPresented.toggle()
                    }
                }

        }
        /// All the SF symbols in use for Kodio
        let symbols: [String: [String]] = ["RadioStations":
                                            ["a.square.fill",
                                             "b.square.fill",
                                             "c.square.fill",
                                             "d.square.fill",
                                             "e.square.fill",
                                             "f.square.fill",
                                             "g.square.fill",
                                             "h.square.fill",
                                             "i.square.fill",
                                             "j.square.fill",
                                             "k.square.fill",
                                             "l.square.fill",
                                             "m.square.fill",
                                             "n.square.fill",
                                             "o.square.fill",
                                             "p.square.fill",
                                             "q.square.fill",
                                             "r.square.fill",
                                             "s.square.fill",
                                             "t.square.fill",
                                             "u.square.fill",
                                             "v.square.fill",
                                             "w.square.fill",
                                             "x.square.fill",
                                             "y.square.fill",
                                             "z.square.fill",
                                             "1.square.fill",
                                             "2.square.fill",
                                             "3.square.fill",
                                             "4.square.fill",
                                             "5.square.fill",
                                             "6.square.fill",
                                             "7.square.fill",
                                             "8.square.fill",
                                             "9.square.fill"
                                            ],
                                           "KodiHosts":
                                            ["building.columns",
                                             "display",
                                             "desktopcomputer",
                                             "laptopcomputer",
                                             "macmini",
                                             "bonjour"
                                            ]
        ]
    }
}

extension PartsView {

    /// View a Kodi host selector
    struct HostSelector: View {
        /// The AppState model that has the hosts information
        @EnvironmentObject var appState: AppState
        /// The KodiConnector model
        @EnvironmentObject var kodi: KodiConnector
        /// The view
        var body: some View {
            if let host = appState.host {
                Button(
                    action: {
                        Task {
                            await kodi.loadLibrary(cache: false)
                        }
                    },
                    label: {
                        Label("Reload \(host.details.description)", systemImage: "arrow.clockwise")
                    }
                )
                Divider()
            }
            ForEach(appState.hosts.filter { $0.status == .configured }) { host in
                Button(
                    action: {
                        appState.selectHost(host: host)
                    },
                    label: {
                        Label("\(host.details.description)\(host.details.isOnline ? "" : "(offline)")", systemImage: host.icon)
                    }
                )
                .disabled(!host.details.isOnline)
            }
        }
    }
}
