//
//  MusicBridge.swift
//  Kodio (macOS)
//
//  © 2022 Nick Berendsen
//

import Foundation
import AppleScriptObjC

/// The Music Bridge class; send AppleScript actions to Music
final class MusicBridge {
    /// AppleScriptObjC object for communicating with Music
    private var bridge: MusicBridgeProtocol
    /// AppleScriptObjC setup
    init() {
        Bundle.main.loadAppleScriptObjectiveCScripts()
        //// create an instance of MusicBridge script object
        let musicBridgeClass: AnyClass = NSClassFromString("MusicBridge")!
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

    /// Set the rating of a Music song
    /// - Parameters:
    ///   - songID: The AppleScript ID of the song
    ///   - rating: The rating
    func setMusicSongRating(songID: Int, rating: Int) {
        bridge.setTrackRating(["\(songID)", "\(rating)"])
    }
    
    /// Send a notification with AppleScript
    /// - Parameters:
    ///   - title: The title of the notification
    ///   - message: The message of the notification
    func sendNotification(title: String, message: String) {
        bridge.sendNotification([title, message])
    }
}

/// The bridge for Music
@objc(NSObject) protocol MusicBridgeProtocol {
    /// Set the rating of a track
    func setTrackRating(_ theTrack: [String])
    /// Get the ASppleScript ID of a track
    func getTrackID(_ theTrack: [String]) -> NSString
    /// Send a notification
    func sendNotification(_ theNotification: [String])
}
