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
    public var subtitle: String? { String(year) + (isCinema ? " 🎬" : "") }
    public var image: String { img }
    public var aspectRatio: CGFloat { Constants.aspectRatio }
    public var circle: Bool { false }
}

extension TVShow: Media {
    public var subtitle: String? { String(episode) }
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
