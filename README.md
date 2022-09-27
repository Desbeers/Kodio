#  Kodio

## A macOS and iPad music remote for [Kodi](https://kodi.tv)

Kodio is written in SwiftUI 4 for macOS Ventura and iPadOS 16. Kodi version 19 *Matrix* is required.

![Screenshot](https://github.com/Desbeers/Kodio/raw/main/screenshot.png)

My goal is to share as much code between the platforms, while still make them feel as *native* as possible. Both versions have exactly the same functionalities except for `rating syncing`, that is macOS only.

Unlike most SwiftUI programmers, my main focus is for macOS. It is a challenge because there is *by far* less information about SwiftUI on macOS. Well, part of the fun.

### macOS

- Kodio can synchronise ratings between Kodi and Apple Music.

### Bugs, bugs, bugs!

Yes, I know. Kodio is a bit buggy and always will be. Learning everyday something new and Kodio will always be work in progress. Part of the hobby! It is not my job. Not even close; I'm actually a seaman with a lot of free time, haha!

## Dependencies

Komodio depends on the following Swift Packages that are in my GitHub account:

- [SwiftlyKodiAPI](https://github.com/Desbeers/swiftlykodiapi/). The Swift API to talk to Kodio.

## How to compile

1. Clone the project.
2. Change the signing certificate to your own.
2. Build and run!
