#  Kodio

## A macOS and iPad music remote for [Kodi](https://kodi.tv)

Kodio is written in SwiftUI 3 for macOS Monterey and iPadOS 15. Kodi version 19 *Matrix* is required.

![Screenshot](https://github.com/Desbeers/Kodio/raw/main/screenshot.png)

My goal is to share as much code between the platforms, while still make them feel as *native* as possible. Both versions have exactly the same functionalities except for `rating syncing`, that is macOS only.

Unlike most SwiftUI programmers, my main focus is for macOS. It is a challenge because there is *by far* less information about SwiftUI on macOS. Well, part of the fun.

### macOS

- Has a fully customisable toolbar (tough!).
- Has a native `Preferences` window.
- All `Menu Bar` items are useful; however, the `About` and `Help` are not truly 100% macOS because they still live in the early 2000's... I know how to make them *old style* but I think it's not worth it. See below.
- Close `Sheets` when pressing *return* on the keyboard.
- Kodio can synchronise ratings between Kodi and Apple Music.

On YouTube, I have a slideshow with screenshots from the macOS version:

[![Kodio screenshots](https://img.youtube.com/vi/n4VwDbXoY0M/0.jpg)](https://www.youtube.com/watch?v=n4VwDbXoY0M)

### Performance

I spend a lot (*lot*) of time to get the performance reasonable. SwiftUI is easy, sometimes too easy, *Observer the whole world and it works*! So I learned a lot about *declarative* coding; that's the keyword for *speed*. I develop on a MacBook Pro from mid 2015 and my iPad is an iPad Pro from 2016. Old stuff, but the performance is pretty good in my opinion.

### Bugs, bugs, bugs!

Yes, I know. Kodio is a bit buggy and always will be. Learning everyday something new and Kodio will always be work in progress. Part of the hobby! It is not my job. Not even close; I'm actually a seaman with a lot of free time, haha!

#### macOS

- The *splitview* between the library and the songs can be a bit funky. SwiftUI gives us a dedicated `VSplitView` but it sucks. So, it's an *appkit* thing who is struggling in the SwiftUI world. Poor thing...
- The `About` box in macOS is something from another world. I override the option with a sheet. I know I can add an *rtf* file to give it some content but it is 2021 now.
- Same for `Help`. Writing a *native help* requires *Black Magic*. I know how to do, however, it does not feel *native* anymore.
- `Swipes` in a `List` do not dismiss themselves. It is already a miracle that it is working on macOS...

#### iOS

- The `Menu` gives errors on the Console but seems to work normal. I don't know why.
- Lots of other *noise* in the log.

#### General

- Disconnecting from the `WebSocket` always gives an error. I just ignore it. I have to disconnect on iOS when going to the *background* or else Apple is very upset to me, hehe...

### More information

See [Kodio Help](https://github.com/Desbeers/Kodio/blob/main/Kodio/General/Help.md) for some more general information about Kodio.

## How to compile

1. Clone the project.
2. Change the signing certificate to your own.
2. Build and run! Kodio has no external dependencies.

## Documentation

    Any code of your own that you haven't looked at for six or more months
    might as well have been written by someone else.
    
    – Eagleson's Law

So, I documented the source code for Kodio...

See [Kodio Reference](https://desbeers.github.io/Kodio/) for the documentation.
