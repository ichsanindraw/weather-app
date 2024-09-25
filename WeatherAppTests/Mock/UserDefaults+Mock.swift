//
//  UserDefaults+Mock.swift
//  WeatherAppTests
//
//  Created by Ichsan Indra Wahyudi on 11/09/24.
//

import Foundation

final class MockUserDefaults: UserDefaults {
    var storedData = [String: Any]()
    
    override func set(_ value: Any?, forKey defaultName: String) {
        storedData[defaultName] = value
    }
    
    override func removeObject(forKey defaultName: String) {
        storedData.removeValue(forKey: defaultName)
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return storedData[defaultName] as? Data
    }
}
