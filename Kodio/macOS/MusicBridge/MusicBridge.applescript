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

    -- Set the playcount of a track
    to setTrackPlaycount: theTrack
        set trackID to item 1 of theTrack as integer
        set trackPlaycount to item 2 of theTrack as integer
        tell application id "com.apple.Music"
            set trk to (first track whose id is trackID)
            set played count of trk to trackPlaycount
        end tell
    end setTrackPlaycount

    -- Set the played date of a track
    to setTrackPlayDate: theTrack
        set trackID to item 1 of theTrack as integer
        set textDate to item 2 of theTrack as strings

        --- Convert Kodi date to Applescript date
        set resultDate to the current date
        set the month of resultDate to (1 as integer)
        set the day of resultDate to (1 as integer)

        set the year of resultDate to (text 1 thru 4 of textDate)
        set the month of resultDate to (text 6 thru 7 of textDate)
        set the day of resultDate to (text 9 thru 10 of textDate)
        set the time of resultDate to 0

        set the hours of resultDate to (text 12 thru 13 of textDate)
        set the minutes of resultDate to (text 15 thru 16 of textDate)
        set the seconds of resultDate to (text 18 thru 19 of textDate)

        --- Update the Music song
        tell application id "com.apple.Music"
            set trk to (first track whose id is trackID)
            set played date of trk to resultDate
        end tell
    end setTrackPlayDate

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

--- HELPERS

-- Convert date function. Call with string in YYYY-MM-DD HH:MM:SS format (time part optional)
to convertDate(textDate)

display dialog "Convert: " & textData
    set resultDate to the current date
    set the month of resultDate to (1 as integer)
    set the day of resultDate to (1 as integer)

    set the year of resultDate to (text 1 thru 4 of textDate)
    set the month of resultDate to (text 6 thru 7 of textDate)
    set the day of resultDate to (text 9 thru 10 of textDate)
    set the time of resultDate to 0

    if (length of textDate) > 10 then
        set the hours of resultDate to (text 12 thru 13 of textDate)
        set the minutes of resultDate to (text 15 thru 16 of textDate)

        if (length of textDate) > 16 then
            set the seconds of resultDate to (text 18 thru 19 of textDate)
        end if
    end if

    return resultDate
end convertDate
