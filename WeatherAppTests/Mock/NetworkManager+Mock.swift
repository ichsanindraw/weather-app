//
//  NetworkManager+Mock.swift
//  WeatherAppTests
//
//  Created by Ichsan Indra Wahyudi on 05/09/24.
//

import Combine

@testable import WeatherApp

class MockNetworkManager: NetworkManager {
    var fetchWeatherCalled = false
    var weatherDataToReturn: WeatherData?
    var errorToReturn: Error?

    override func fetchWeather(_ lat: Double, _ long: Double) -> AnyPublisher<WeatherData, Error> {
        fetchWeatherCalled = true
        if let error = errorToReturn {
            return Fail(error: error).eraseToAnyPublisher()
        } else if let weatherData = weatherDataToReturn {
            return Just(weatherData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Empty().eraseToAnyPublisher()
    }
}

