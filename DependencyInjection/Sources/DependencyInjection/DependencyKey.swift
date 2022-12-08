//
//  DependencyKey.swift
//
//
//  Created by ned on 31/10/22.
//

public protocol DependencyKey {
    associatedtype Value
    static var currentValue: Self.Value { get set }
}
