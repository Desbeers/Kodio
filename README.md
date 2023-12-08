#  Kodio

## A macOS, iPadOS and visionOS music remote for [Kodi](https://kodi.tv)

![Icon](https://github.com/Desbeers/Kodio/raw/main/Images/icon.png)

**Kodio** is written in SwiftUI 5 and needs Xcode 15 to compile. Kodi version 19 *Matrix* is required.

- macOS Sonoma
- iPadOS 17
- visionOS 1

![Screenshot](https://github.com/Desbeers/Kodio/raw/main/Images/screenshot-macOS.jpg)

Unlike most SwiftUI programmers, my focus is on macOS. It is a challenge because there is *by far* less information about SwiftUI on macOS. Well, part of the fun.

There are plenty Kodi music remotes for iOS and iPadOS.

For macOS, there is none, except mine. I think it is also a little bit great, haha!
Music and Kodi.

### Bugs, bugs, bugs!

Yes, I know. **Kodio** is a bit buggy and always will be. Learning everyday something new and **Kodio** will always be work in progress. Part of the hobby! It is not my job. Not even close; I'm actually a seaman with a lot of free time, haha!

- Kodio depends on Bonjour to find your Kodi hosts.
- The visionOS version is only tested in the simulator but looks good!

## Dependencies

**Kodio** depends on the following Swift Package that is also in my GitHub account:

- [SwiftlyKodiAPI](https://github.com/Desbeers/swiftlykodiapi/). The Swift API to talk to Kodio.

## Code documentation

The source code of **Kodio** is well [documented](https://desbeers.github.io/Kodio/).

## How to compile

Xcode 15 is required.

1. Clone the project.
2. Change the signing certificate to your own.
2. Build and run!
