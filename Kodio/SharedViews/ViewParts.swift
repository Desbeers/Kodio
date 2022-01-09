//
//  ViewModifiers.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

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

/// View a Kodi host selector
struct ViewHostSelector: View {
    /// The AppState model that has the hosts information
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        if !appState.selectedHost.ip.isEmpty {
            Button(
                action: {
                    appState.viewAlert(type: .scanLibrary)
                },
                label: {
                    Label("Reload \(appState.selectedHost.description)", systemImage: "arrow.clockwise")
                }
            )
            Divider()
        }
        ForEach(appState.hosts.filter { $0.selected == false }) { host in
            Button(
                action: {
                    Hosts.switchHost(selected: host)
                },
                label: {
                    Label(host.description, systemImage: "k.circle")
                }
            )
        }
    }
}

/// View modifier for Form Views
struct ViewModifierForm: ViewModifier {
#if os(macOS)
    func body(content: Content) -> some View {
        content
            .disableAutocorrection(true)
        /// Labels look terrible on macOS
            .labelsHidden()
    }
#endif
#if os(iOS)
    func body(content: Content) -> some View {
        content
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
#endif
}
