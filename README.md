# Stats
[![Codemagic build status](https://api.codemagic.io/apps/636919edbf9296736cfc1709/build/status_badge.svg)](https://codemagic.io/)
[![swift-version](https://img.shields.io/badge/swift-5.7-orange.svg)](https://github.com/apple/swift)
[![xcode-version](https://img.shields.io/badge/xcode-14.2-blue)](https://developer.apple.com/xcode/)
[![license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](LICENSE)

My personal iOS app to track things I've watched/read/listened/played, written in SwiftUI

## Screenshots
![screenshots](https://user-images.githubusercontent.com/11541888/225115254-218c3a9c-f8d7-4511-bd7e-0b194827a458.png)

## Motivation
The main motivation behind the development of Stats was to learn and explore advanced concepts in iOS development, such as:
* Building charts using [Swift Charts](https://developer.apple.com/documentation/charts)
* Dependency injection (based on this [SwftLee article](https://www.avanderlee.com/swift/dependency-injection/))
* Project modularization using local Swift packages
* Persistence and full offline support (using [Boutique](https://github.com/mergesort/Boutique))
* Continuous integration and automated deployment (using [CodeMagic](https://codemagic.io/))

## Notes
* Requires iOS 16+
* iPad not supported

## Third party libraries
* [Nuke](https://github.com/kean/Nuke) - Image loading system
* [Boutique](https://github.com/mergesort/Boutique) - A persistence library for state-driven iOS apps
* [SwiftDate](https://github.com/malcommac/SwiftDate) - Toolkit to parse, validate, manipulate, compare and display dates, time & timezones in Swift
* [DominantColor](https://github.com/indragiek/DominantColor) - Finding dominant colors of an image using k-means clustering

## License
Stats is available under the MIT license. See [LICENSE](LICENSE) file for further information.
