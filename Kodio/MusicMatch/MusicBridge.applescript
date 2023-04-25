--
--  MusicBridge.applescript
--  Kodio
--
--  © 2023 Nick Berendsen
--

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

    -- Set the values of a track
    to setTrackValues: theTrack
        set trackID to item 1 of theTrack as integer
        set trackPlaycount to item 2 of theTrack as integer
        set textDate to item 3 of theTrack as strings
        set trackRating to item 4 of theTrack as integer

        --- Convert Kodi date to Applescript date

        set resultDate to the current date
        set the year of resultDate to (text 1 thru 4 of textDate)
        set the month of resultDate to (text 6 thru 7 of textDate)
        set the day of resultDate to (text 9 thru 10 of textDate)
        set the time of resultDate to 0
        set the hours of resultDate to (text 12 thru 13 of textDate)
        set the minutes of resultDate to (text 15 thru 16 of textDate)
        set the seconds of resultDate to (text 18 thru 19 of textDate)

        tell application id "com.apple.Music"
            set trk to (first track whose id is trackID)
            set playedDate to played date of trk
            set played count of trk to trackPlaycount
            set played date of trk to resultDate
            set rating of trk to trackRating
        end tell
    end setTrackValues

    -- Send a notification
    to sendNotification: theNotification
        set theTitle to item 1 of theNotification as strings
        set theMessage to item 2 of theNotification as strings
        display notification theMessage with  title theTitle sound name "Frog"
    end setNotification

end script
