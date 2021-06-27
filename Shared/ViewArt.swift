///
/// ViewArt.swift
/// Kodio (Shared)
///
/// © 2021 Nick Berendsen
///

import SwiftUI

// MARK: - ViewArtArtist (view)

/// Show the artist thumbnail

struct ViewArtArtist: View {
    /// The artist object
    var artist: ArtistFields
    /// The view
    var body: some View {
        RemoteKodiImage(url: artist.thumbnail)
            .aspectRatio(contentMode: .fit)
            .frame(width: 50, height: 50)
            .cornerRadius(5)
    }
}

// MARK: - ViewArtAlbum (view)

/// Show the album thumbnail

struct ViewArtAlbum: View {
    /// The album object
    var album: AlbumFields
    /// The view
    var body: some View {
        RemoteKodiImage(url: album.thumbnail)
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .cornerRadius(5)
    }
}

// MARK: - ViewArtSong (view)

/// Get the album thumbnail; sometimes songs have different art than the album for some unknown reason
/// and you end up with a lot, lot lot of images in the cache...

struct ViewArtSong: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// The song object
    var song: SongFields
    /// The view
    var body: some View {
        Group {
            if let index = kodi.albums.all.firstIndex(where: { $0.albumID == song.albumID }) {
                RemoteKodiImage(url: kodi.albums.all[index].thumbnail, failure: Image("DefaultCoverArt"))
            } else {
                Image("DefaultCoverArt")
                    .resizable()
            }
        }
        .frame(width: 40, height: 40)
        .cornerRadius(5)
    }
}

// MARK: - ViewArtFanart (view)

/// Show the fanart

struct ViewArtFanart: View {
    /// The object that has it all
    @EnvironmentObject var kodi: KodiClient
    /// State of application
    @EnvironmentObject var appState: AppState
    /// The view
    @ViewBuilder
    var body: some View {
        if let fanart = appState.selectedArtist?.fanart {
            RemoteKodiImage(url: fanart, failure: Image("DefaultFanart"))
                .aspectRatio(1.78, contentMode: .fit)
                .cornerRadius(5)
        } else {
            Image("DefaultFanart")
                .resizable()
                .aspectRatio(1.78, contentMode: .fit)
                .cornerRadius(5)
        }
    }
}
