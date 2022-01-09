//
//  ViewArt.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

import SwiftUI

/// View a remote art
struct ViewRemoteArt: View {
    /// The kind of art
    enum ArtOptions {
        /// Show the fanart
        case fanart
        /// Show the thumbnail
        case thumbnail
    }
    /// The ``LibraryItem`` to show
    let item: LibraryItem
    /// The art type to show
    let art: ArtOptions
    /// The optional ``Image`` to show
    @State private var image: Image?
    /// The cached images
    @Environment(\.remoteArt) private var remoteArt
    /// The view
    var body: some View {
        VStack {
            if let image = image {
                image
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .task(priority: .high) {
            await loadArt(item: item)
        }
        .id(art == .thumbnail ? item.thumbnail : item.fanart)
    }

    /// Fetch the art
    /// - Parameter item: A ``LibraryItem``
    func loadArt(item: LibraryItem) async {
        
        switch item.media {
        case .song, .album, .artist:
            do {
                image = try await remoteArt.getArt(
                    item: item,
                    art: art == .thumbnail ? item.thumbnail : item.fanart
                )
            } catch {
                print(error)
            }
        default:
            image = Image(systemName: item.icon)
        }
    }
}

/// View thumbnail for the item in the player
/// - note: I don't use the provided thumbnail from the PlayerItem because it might be different
///         from the album cover. Song cover is not always album cover and I don't want to cache them all.
struct ViewPlayerArt: View {
    /// The item in the player
    let item: Player.PlayerItem
    /// The size of the image
    var size: CGFloat = 30
    /// The fallback image
    var fallback: String = "Record"
    /// The AppState model
    @EnvironmentObject var appState: AppState
    /// The view
    var body: some View {
        if let song = Library.shared.songs.all.first(where: { $0.songID == item.songID }) {
            /// Songs
            ViewRemoteArt(item: song, art: .thumbnail)
        } else if let station = appState.radioStations.first(where: { $0.stream == item.mediaPath }) {
            /// Radio station
            ViewRadioStationArt(station: station)
                .frame(width: size, height: size)
        } else {
            /// Fallback
            Image(fallback)
                .resizable()
                .frame(width: size, height: size)
        }
    }
}

/// Compose art for a Radio Station
struct ViewRadioStationArt: View {
    /// The radio station that needs art
    let station: RadioStationItem
    /// The View
    var body: some View {
        ZStack {
            Color(hexString: station.bgColor)
            Image(systemName: station.icon)
                .resizable()
            /// - Note: A nice trick to get only the 'base' of a symbol
                .foregroundStyle(
                    Color(hexString: station.fgColor),
                    Color.clear
                )
        }
    }
}
