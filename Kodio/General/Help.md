# Requirements

[Kodi](https://kodi.tv) version 19 *Matrix* is required because it gave us a lot of extra stuff for the music library. I have no intentions to make it work with older versions because life goes on!

Also, Kodio is written in SwiftUI 3 so that means macOS Monterey or iOS version 15. Again, the past is the past.

# Filosofy

Kodio is just about your music. It does not show 'playing time' or 'progress`. It does not have a 'stop' button. You will never stop listening to your music; you will just pause it.

# Usage

Well, I think it is pretty straightforward. Maybe there is only one thing unusual; your library lists are `toggle buttons`. Select an artist or deselect it again. I like that. Same for genres and albums.

Play or shuffle your songs with the buttons above the songlist.

If you swipe (or *right click*) on a song you can play it. If it is already in the queue, it will just jump to that song. If not, the queue will be emptied and the song will play.

There is no option to add a new song to the `queue`. See below about settings...

Click (or tap) the small image in the toolbar to open the *Playing Queue*. You can jump in your Queue.

# Playlists

Your Kodi playlists are loaded when Kodio is started. If you *add* or *delete* playlists; Kodio will not know until you either restart it or reload the library.

Kodio is smart enough to get *the latest and greatest* for a playlist when you select it in the sidebar.

# ReplayGain

Well, as a *real* lover of my own library, my music is tagged with [ReplayGain](https://en.wikipedia.org/wiki/ReplayGain) values. When I start an album, Kodi's ReplayGain setting wil be set to 'Album'. When I play a list of songs that are *not* an album, Kodio will set Kodi's ReplayGain setting to 'songs'.

**Yes, Kodio will alter your ReplayGain settings!**

See below about settings...

# I cannot connect to my host!

Make sure remote control is enabled in Kodi

Turn on the following settings in Kodi to enable using this remote control:

    Settings → Services → Control → Allow programs on other systems to control Kodi → ON

    Settings/Services/Control → Allow control of Kodi via HTTP → ON

Take note of the Port number, the Username and the Password (if any).

# There are no settings!

No, because it is not needed, haha!

I made Kodio exactly how I want it to be so I have no need for any settings. You want something different? Just change the source code or send a pull request if it is something worth to share.

# Will this ever be in the Apple Store?

No. See above; I wrote this application just for fun and for my own use. I share it because I think thats a fair thing to do. Thanks to *sharing* I was able to write this. I want to give something back. The charm of *Open Source*.

Publishing an application gives responsibility. I don't want that. Also, I don't have a Developer Account, cheap as I am. Kodio expires on my iPad after a few days but I don't really care because I'm primarily a macOS user

# Bugs, bugs, bugs!

Yes, I know. Kodio is a bit buggy and always will be. Learning everyday something new and Kodio will always be work in progress. Part of the hobby! It is not my job.

Kodio is written in SwiftUI; very enjoyable, however, far from perfect; especially on macOS, unfortunately...

## macOS

- The `splitview` between the library and the songs can be a bit funky. SwiftUI gives us a dedicated `VSplitView` but it sucks. So, it's an *appkit* thing who is struggling in the SwiftUI world. Poor thing...
- The `About` box in macOS is something from another world. I override the option with a sheet. I know I can add a `rtf` file to give it some content but it is 2021 now.
- Same for `Help`. Writing a *native* `Help` requires *Black Magic*. I know how to do, however, it does not feel *native* anymore.
- `Swipes` in a `List` do not dismiss themselves. It is already a miracle that it is working on macOS...
- If you modify the toolbar it will reset to default again. I think it's a bug. Also, showing 'text' only in the toolbar makes no sense... It's all Work in Progress!

## iOS

- The 'Menu' gives errors on the Console but seems to work normal. I don't know why.
- Lots of other *noise* in the log.

## General

- `Navigationlinks` are terrible; I use my own implementation. The result is that the `sidebar` buttons don't feel completely *native*.
- Disconnecting from the `WebSocket` always gives an error. I just ignore it. I have to disconnect on iOS when going to the *background* or else Apple is very upset to me, hehe...
- Radio channels are hard-coded at the moment...

*And for your info; the rotating LP you see in the background is turning at a perfect 33 1/3... Details!*

Kodio is available on [Github](https://github.com/desbeers/kodio) with a GPL-3.0 License.
