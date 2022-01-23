script MusicBridge
	
	property parent : class "NSObject"

    -- Get the ID of a track
    to getTrackID: theTrack
        set trk to getTrackFromLibrary_(theTrack)
        tell application id "com.apple.Music"
            try
                return id of trk
            on error number -1728 -- current track is not available
                return missing value -- nil
            end try
        end tell
    end getTrackID

    -- Set the rating of a track
    to setTrackRating: theTrack
        set trackID to item 1 of theTrack as integer
        set trackRating to item 2 of theTrack as integer
        tell application id "com.apple.Music"
            set trk to (first track whose id is trackID)
            set rating of trk to trackRating
        end tell
    end setTrackRating
	
    -- Get a track from the Music Library
    to getTrackFromLibrary: theTrack
        set trackName to item 1 of theTrack as strings
        set trackAlbum to item 2 of theTrack as strings
        set trackNumber to item 3 of theTrack as strings
        tell application id "com.apple.Music"
            set trk to (first track whose name is trackName and album = trackAlbum and track number = trackNumber)
        end tell
        return trk
    end getTrackFromLibrary

    -- Send a notification
    to sendNotification: theNotification
        set theTitle to item 1 of theNotification as strings
        set theMessage to item 2 of theNotification as strings
        display notification theMessage with  title theTitle sound name "Frog"
    end setNotification

end script
