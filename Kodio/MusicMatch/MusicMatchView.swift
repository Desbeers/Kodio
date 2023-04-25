//
//  MusicMatchView.swift
//  Kodio
//
//  Created by Nick Berendsen on 14/04/2023.
//

import SwiftUI
import SwiftlyKodiAPI

/// The View to sync ratings and playcounts between Kodi and Music
struct MusicMatchView: View {
    /// The KodiConnector model
    @EnvironmentObject var kodi: KodiConnector
    /// The MusicMatch model
    @StateObject var musicMatch = MusicMatchModel()
    /// The items in the table
    @State private var items: [MusicMatchModel.Item] = []
    /// Confirmation dialog
    @State private var isPresentingConfirm: Bool = false
    /// Sort order for the table
    @State var sortOrder: [KeyPathComparator<MusicMatchModel.Item>] = [
        .init(\.kodi.lastPlayed, order: SortOrder.reverse)
    ]

    // MARK: Body of the View

    /// The body of the View
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                Text("Music Match")
                    .font(.title)
                Text("Match ratings and playcounts between Kodi and Music")
                    .font(.subheadline)
            }
            .modifier(PartsView.ListHeader())
            table
            actions
        }
        .disabled(musicMatch.status.busy)
        .animation(.default, value: musicMatch.status)
        .animation(.default, value: items)
        .onChange(of: musicMatch.playcountAction) { _ in
            matchSongs()
        }
        .onChange(of: musicMatch.ratingAction) { _ in
            matchSongs()
        }
    }

    // MARK: Table of the View

    /// The table of the View
    var table: some View {
        Table(sortOrder: $sortOrder) {
            TableColumn("Title", value: \.title)
            TableColumn("Action") { item in
                Button(action: {
                    Task {
                        await musicMatch.syncSong(song: item)
                        await musicMatch.setMusicMatchCache()
                        items = musicMatch.musicMatchItems
                    }
                }, label: {
                    Label("Sync", systemImage: item.matched ? "infinity" : "minus")
                        .foregroundColor(.accentColor)
                })
                .buttonStyle(.plain)
                .disabled(item.itemInSync)
            }
            .width(80)
            TableColumn("Artist", value: \.artist)
            TableColumn("Album", value: \.album)
            TableColumn("Sync values") { item in
                VStack(alignment: .leading) {
                    Text("Playcount: \(item.sync.playcount)")
                    Text(item.sync.lastPlayed)
                        .font(.caption)
                    PartsView.ratings(rating: item.sync.rating)
                }
            }
            TableColumn("Kodi Play", value: \.kodi.lastPlayed) { item in
                VStack(alignment: .leading) {
                    Text("Playcount: \(item.kodi.playcount)")
                    Text(item.kodi.lastPlayed)
                        .font(.caption)
                }
                .foregroundColor(item.kodi == item.sync ? .green : .red)
            }
            TableColumn("Kodi Rating", value: \.kodi.rating) { item in
                PartsView.ratings(rating: item.kodi.rating)
                    .foregroundColor(item.kodi.rating == item.sync.rating ? .green : .red)
            }
            TableColumn("Music Play", value: \.music.lastPlayed) { item in
                VStack(alignment: .leading) {
                    Text("Playcount: \(item.music.playcount)")
                    Text(item.music.lastPlayed)
                        .font(.caption)
                }
                .foregroundColor(item.music == item.sync ? .green : .red)
            }
            TableColumn("Music Rating", value: \.music.rating) { item in
                PartsView.ratings(rating: item.music.rating)
                    .foregroundColor(item.music.rating == item.sync.rating ? .green : .red)
            }
        } rows: {
            // ForEach(items.filter { $0.itemInSync == false }.sorted(using: sortOrder)) { item in
            ForEach(items.sorted(using: sortOrder)) { item in
                TableRow(item)
            }
        }
    }
    // MARK: Actions of the View

    /// The actions of the View
    var actions: some View {
        VStack {
            HStack {
                Button(
                    action: {
                        matchSongs()
                    },
                    label: {
                        Text(musicMatch.status == .musicMatched ? "Match songs again" : "Match songs")
                    }
                )
                Button(
                    action: {
                        isPresentingConfirm = true
                    },
                    label: {
                        Text("Reset matches")
                    }
                )
                .disabled(items.isEmpty)
            }
            .padding()
            VStack {
                Text(musicMatch.status.rawValue)
                    .font(.headline)
                ProgressView(value: musicMatch.progress.current, total: musicMatch.progress.total)
                    .opacity(musicMatch.status.busy ? 1 : 0)
                    .frame(width: 400)
            }
            HStack {
                Picker("New Match:", selection: $musicMatch.playcountAction) {
                    ForEach(MusicMatchModel.PlaycountAction.allCases, id: \.self) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .frame(width: 240)
                Picker("Ratings:", selection: $musicMatch.ratingAction) {
                    ForEach(MusicMatchModel.RatingAction.allCases, id: \.self) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                .frame(width: 240)
                Button(
                    action: {
                        syncAllItems()
                    },
                    label: {
                        Text("Sync all songs")
                    }
                )
                .disabled(musicMatch.status != .musicMatched)
            }
            .padding(.bottom)
        }
        .confirmationDialog(
            "Are you sure?",
            isPresented: $isPresentingConfirm,
            actions: {
                Button("Reset matches", role: .destructive) {
                    do {
                        try Cache.delete(key: "MusicMatchItems")
                    } catch {}
                    matchSongs()
                }
            },
            message: {
                Text("this will remove the playcount connection between Kodi and Music")
            }
        )
    }

    // MARK: Private functions

    /// Match the Kodi and Music songs
    private func matchSongs() {
        Task {
            items = []
            musicMatch.status = .musicMatching
            await musicMatch.matchSongs()
            items = musicMatch.musicMatchItems
            musicMatch.status = .musicMatched
        }
    }

    /// Sync all songs between Kodi and Music
    private func syncAllItems() {
        Task {
            kodi.scanningLibrary = true
            musicMatch.status = .syncAllSongs
            await musicMatch.syncAllSongs()
            items = musicMatch.musicMatchItems
            musicMatch.status = .musicMatched
            kodi.scanningLibrary = false
            await KodiConnector.shared.getAudioLibraryUpdates()
        }
    }
}
