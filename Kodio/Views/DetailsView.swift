//
//  DetailsView.swift
//  Kodio
//
//  Created by Nick Berendsen on 26/07/2022.
//

import SwiftUI
import SwiftlyKodiAPI

/// The Details View for the Browser View
struct DetailsView: View {
    /// The selected ``Router``
    let router: Router
    /// The selected `KodiItem`
    let selectedItem: (any KodiItem)?
    /// Rotate the record
    @State private var rotate: Bool = false
    /// The body of the `View`
    var body: some View {
        ScrollView {
            Text(selectedItem?.title ?? router.sidebar.title)
                .font(.title2)
                .lineLimit(1)
            Text(selectedItem?.subtitle ?? router.sidebar.description)
                .font(.caption)
            VStack {
                RadialGradient(gradient: Gradient(colors: [.accentColor, .black]), center: .center, startRadius: 0, endRadius: 280)
                    .saturation(0.4)
                    .overlay(
                        overlay
                            .scaledToFill()
                            .foregroundColor(.white)
                    )
            }
            .aspectRatio(1.78, contentMode: .fit)
            .cornerRadius(3)
            Text(selectedItem?.description ?? "")
                .padding(.bottom)
        }
        .id(selectedItem?.id)
        .padding(.top)
        .padding(.horizontal)
    }

    /// Overlay the base artwork
    @ViewBuilder var overlay: some View {
        if let item = selectedItem {
            switch item.media {
            case .artist:
                KodiArt.Fanart(item: item)
            case .album:
                ZStack {
                    HStack {
                        Color.clear
                        PartsView.RotatingRecord(title: item.title,
                                                 subtitle: item.subtitle,
                                                 details: item.details,
                                                 rotate: .constant(true)
                        )
                    }
                    HStack {
                        KodiArt.Poster(item: item)
                            .scaledToFit()
                            .cornerRadius(2)
                            .padding(.leading)
                        Color.clear
                    }
                }
                .cornerRadius(2)
                .padding(1)
            default:
                EmptyView()
            }
        } else {
            Image(systemName: router.sidebar.icon)
                .font(.system(size: 80))
                .foregroundColor(.white)
                .shadow(radius: 20)
        }
    }
}
