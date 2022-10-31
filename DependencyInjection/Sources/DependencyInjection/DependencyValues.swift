//
//  File.swift
//  
//
//  Created by ned on 31/10/22.
//

public struct DependencyValues {
    private static var current = DependencyValues()
    
    public static subscript<K>(key: K.Type) -> K.Value where K: DependencyKey {
        get { key.currentValue }
        set { key.currentValue = newValue }
    }
    
    public static subscript<T>(_ keyPath: WritableKeyPath<DependencyValues, T>) -> T {
        get { current[keyPath: keyPath] }
        set { current[keyPath: keyPath] = newValue }
    }
}
