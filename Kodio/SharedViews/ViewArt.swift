//
//  ViewArt.swift
//  Kodio
//
//  © 2021 Nick Berendsen
//

import SwiftUI

// MARK: - View art

/// View artist art
struct ViewArtArtist: View {
    /// The artist object
    var artist: Library.ArtistItem
    /// The size of the image
    var size: CGFloat = 10
    /// The view
    var body: some View {
        RemoteArt(url: artist.thumbnail, failure: Image(systemName: artist.icon))
            .cornerRadius(4)
    }
}

/// View album thumbnail
struct ViewArtAlbum: View {
    /// The album object
    var album: Library.AlbumItem
    /// The size of the image
    var size: CGFloat = 10
    /// The view
    var body: some View {
        RemoteArt(url: album.thumbnail, failure: Image(systemName: album.icon))
            .cornerRadius(4)
    }
}

/// View song thumbnail
/// - note: It actualy use the album thumbnail as assigned when loading the songs
struct ViewArtSong: View {
    /// The song object
    let song: Library.SongItem
    /// The size of the image
    var size: CGFloat = 10
    /// The view
    var body: some View {
        RemoteArt(url: song.thumbnail, failure: Image(systemName: song.icon))
            .cornerRadius(2)
    }
}

/// View thumbnail for the item in the player
/// - note: I don't use the provided thumbnail from the PlayerItem because it might be different
///         from the album cover. Song cover is not always album cover and I don't want to cache them all.
struct ViewArtPlayer: View {
    /// The item in the player
    let item: Player.PlayerItem
    /// The size of the image
    var size: CGFloat = 30
    /// The fallback image
    var fallback: String = "Record"
    /// The view
    var body: some View {
        /// Songs
        if let song = Library.shared.allSongs.first(where: { $0.songID == item.songID }) {
            RemoteArt(url: song.thumbnail, failure: Image(systemName: song.icon))
            /// Radio station
        } else if let stream = Library.shared.radioStations.first(where: { $0.stream == item.mediapath }) {
            Image(stream.thumbnail)
                .resizable()
                .frame(width: size, height: size)
            /// Fallback
        } else {
            Image(fallback)
                .resizable()
                .frame(width: size, height: size)
        }
    }
}
