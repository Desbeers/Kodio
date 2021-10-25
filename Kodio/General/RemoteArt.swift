//
//  RemoteArt.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

struct RemoteArt: View {
    /// The remote url for the image
    let url: String
    /// Image to show when we have a failure
    var failure: Image = Image(systemName: "questionmark")
    /// The view
    var body: some View {
        AsyncImage(
            url: URL(string: url.kodiImageUrl())!
        ) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .scaledToFit()
            case .success(let image):
                image
                    .resizable()
            case .failure:
                failure
                    .resizable()
                    .padding(4)
                    .background(.gray)
                    .foregroundColor(.black)
            @unknown default:
                EmptyView()
            }
        }
    }
}
