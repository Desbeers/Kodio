//
//  MusicBridge.swift
//  Kodio
//
//  © 2022 Nick Berendsen
//

#if os(macOS)

import Foundation
import AppleScriptObjC

/// The Music Bridge class; send AppleScript actions to Music
final class MusicBridge {
    /// AppleScriptObjC object for communicating with Music
    private var bridge: MusicBridgeProtocol
    /// AppleScriptObjC setup
    init() {
        Bundle.main.loadAppleScriptObjectiveCScripts()
        // swiftlint:disable:next force_unwrapping
        let musicBridgeClass: AnyClass = NSClassFromString("MusicBridge")!
        // swiftlint:disable:next force_cast
        self.bridge = musicBridgeClass.alloc() as! MusicBridgeProtocol
    }
}

extension MusicBridge {

    /// Get the AppleScript ID for a song
    /// - Parameters:
    ///   - title: The title of the song
    ///   - album: The album of the song
    ///   - track: The track of the song
    /// - Returns: An AppleScript ID
    /// - Note: Persistent ID between AppleScript and iTunesLibrary do not match
    ///         so we have to search by name, album and track number
    ///         to make sure we get the correct track.
    func getMusicSongID(title: String, album: String, track: Int) -> Int {
        return Int(bridge.getTrackID([title, album, "\(track)"]).intValue)
    }

    /// Set the sync values of a music song
    /// - Parameters:
    ///   - songID: The AppleScript ID of the song
    ///   - values: The values
    func setMusicSongValues(songID: Int, values: MusicMatchModel.Values) {
        bridge.setTrackValues(
            [
                "\(songID)",
                "\(values.playcount)",
                "\(values.lastPlayed)",
                "\(values.rating * 10)"
            ]
        )
    }

    /// Set the rating of a music song
    /// - Parameters:
    ///   - songID: The AppleScript ID of the song
    ///   - rating: The rating
    func setMusicSongRating(songID: Int, rating: Int) {
        bridge.setTrackRating(["\(songID)", "\(rating)"])
    }

    /// Set the playcount of a music song
    /// - Parameters:
    ///   - songID: The AppleScript ID of the song
    ///   - playcount: The playcount
    func setMusicSongPlaycount(songID: Int, playcount: Int) {
        bridge.setTrackPlaycount(["\(songID)", "\(playcount)"])
    }

    /// Set the play date of a music song
    /// - Parameters:
    ///   - songID: The AppleScript ID of the song
    ///   - playDate: The play date
    func setMusicSongPlayDate(songID: Int, playDate: String) {
        bridge.setTrackPlayDate(["\(songID)", playDate])
    }

    /// Send a notification with AppleScript
    /// - Parameters:
    ///   - title: The title of the notification
    ///   - message: The message of the notification
    func sendNotification(title: String, message: String) {
        bridge.sendNotification([title, message])
    }
}

/// The bridge to talk to Music via AppleScript
@objc(NSObject) protocol MusicBridgeProtocol {
    /// Set the values of a track
    func setTrackValues(_ theTrack: [String])
    /// Set the rating of a track
    func setTrackRating(_ theTrack: [String])
    /// Set the playcount of a track
    func setTrackPlaycount(_ theTrack: [String])
    /// Set the play date of a track
    func setTrackPlayDate(_ theTrack: [String])
    /// Get the AppleScript ID of a track
    func getTrackID(_ theTrack: [String]) -> NSString
    /// Send a notification
    func sendNotification(_ theNotification: [String])
}

#endif
