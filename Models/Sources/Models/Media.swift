//
//  Media.swift
//
//
//  Created by ned on 01/11/22.
//

import Foundation

private enum Constants {
    static let aspectRatio: CGFloat = 0.7
}

@available(iOS 13.0, *)
public protocol Media {
    var id: String { get }
    var title: String { get }
    var subtitle: String? { get }
    var image: String { get }
    var aspectRatio: CGFloat { get }
    var circle: Bool { get }
}

extension Movie: Media {
    public var subtitle: String? { lastWatched.formatted(date: .abbreviated, time: .omitted) + (isCinema ? " 🎬" : "") }
    public var image: String { img }
    public var aspectRatio: CGFloat { Constants.aspectRatio }
    public var circle: Bool { false }
}

extension TVShow: Media {
    public var subtitle: String? { episode }
    public var image: String { img }
    public var aspectRatio: CGFloat { Constants.aspectRatio }
    public var circle: Bool { false }
}

extension Book: Media {
    public var subtitle: String? { author }
    public var image: String { img }
    public var aspectRatio: CGFloat { Constants.aspectRatio }
    public var circle: Bool { false }
}

extension Artist: Media {
    public var title: String { name }
    public var subtitle: String? { nil }
    public var image: String { img }
    public var aspectRatio: CGFloat { 1 }
    public var circle: Bool { true }
}

extension Game: Media {
    public var title: String { name }
    public var subtitle: String? { String(year) }
    public var image: String { img }
    public var aspectRatio: CGFloat { Constants.aspectRatio }
    public var circle: Bool { false }
}

// MARK: - AnyMediaModel
/// A simple `any Media` wrapper to fix  `Type ‘any Media’ cannot conform to ‘Identifiable’`
@available(iOS 13.0, *)
public struct AnyMediaModel: Identifiable {
    public var base: any Media
    public var id: String { base.id }
    
    public init(base: any Media) {
        self.base = base
    }
}

@available(iOS 13.0, *)
public extension Media {
    var asMediaModel: AnyMediaModel {
        .init(base: self)
    }
}


@available(iOS 13.0, *)
public extension Array where Element: Media {
    var asMediaModels: [AnyMediaModel] {
        map({ media in AnyMediaModel.init(base: media) })
    }
}
