//
//  RotatingRecordModel.swift
//  Kodio
//
//  © 2023 Nick Berendsen
//

import SwiftUI
import SwiftlyKodiAPI

/// The model to observe ``PartsView/RotatingRecord``
class RotatingRecordModel: ObservableObject {
    /// Do we want to rotate or not?
    private var rotate: Bool = false
    /// Are we rotating or not?
    @Published var rotating: Bool = false
    /// A flip/flop when a rotation is completed
    var status: Bool = false {
        didSet {
            if rotate != rotating {
                /// Stop the rotation
                rotating = false
            }
        }
    }
    /// The animation
    var foreverAnimation: Animation {
        Animation.linear(duration: 3.6)
            .repeatForever(autoreverses: false)
    }

    /// Start the rotating animation
    @MainActor
    func startRotating() async {
        do {
            /// Sleep for a moment before we start to avoid hickups
            try await Task.sleep(until: .now + .seconds(1), clock: .continuous)
            /// Start the rotation
            rotating = true
            rotate = true
        } catch { }
    }

    /// Stop the rotating animation
    /// - Note: the animation will only stop when the rotating is completed
    func stopRotating() {
        rotate = false
    }
}

extension RotatingRecordModel {

    /// The rotate animation
    /// - Note: A 'GeometryEffect' instead of a simple animation so we can observe it
    struct Rotate: GeometryEffect, @unchecked Sendable {
        /// Do we want to rotate or not?
        var rotate: Bool
        /// A flip/flop when a rotation is completed
        @Binding var status: Bool
        /// The percentage of the animation
        var percent: Double
        /// The animation data
        var animatableData: Double {
            get { percent }
            set { percent = newValue }
        }
        /// Init the struct
        init(rotate: Bool, status: Binding<Bool>) {
            self.rotate = rotate
            _status = status
            self.percent = rotate ? 1.0 : 0.0
        }
        /// The rotating effect
        func effectValue(size: CGSize) -> ProjectionTransform {
            /// Flip/flop the state when the animation is completed
            /// - Note: this must be done on the main actor
            if percent == 1.0 {
                Task { @MainActor in
                    self.status.toggle()
                }
            }
            let rotationTransform = CGAffineTransform(rotationAngle: 2 * .pi * percent)
            var transform = CGAffineTransform(translationX: -size.width / 2, y: -size.height / 2)
            transform = transform.concatenating(rotationTransform)
            let anchorPointTransform = CGAffineTransform(translationX: size.width / 2, y: size.height / 2)
            return ProjectionTransform(transform)
                .concatenating(ProjectionTransform(anchorPointTransform))
        }
    }
}
