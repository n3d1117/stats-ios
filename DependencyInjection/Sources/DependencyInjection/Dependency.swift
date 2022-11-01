//
//  Dependency.swift
//  
//
//  Created by ned on 31/10/22.
//

@propertyWrapper
public struct Dependency<T> {
    private let keyPath: WritableKeyPath<DependencyValues, T>
    public var wrappedValue: T {
        get { DependencyValues[keyPath] }
        set { DependencyValues[keyPath] = newValue }
    }

    public init(_ keyPath: WritableKeyPath<DependencyValues, T>) {
        self.keyPath = keyPath
    }
}
