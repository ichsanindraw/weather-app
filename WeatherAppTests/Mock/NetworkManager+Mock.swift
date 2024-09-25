//
//  NetworkManager+Mock.swift
//  WeatherAppTests
//
//  Created by Ichsan Indra Wahyudi on 05/09/24.
//

import XCTest
import Combine

@testable import WeatherApp

class MockNetworkManager: NetworkManager {
    var isError = false
    var weatherData: WeatherData?

    override func fetchWeather(_ lat: Double, _ long: Double) -> AnyPublisher<WeatherData, Error> {
        guard !isError else {
            return Fail(error: URLError(.badServerResponse))
                .eraseToAnyPublisher()
        }
        
        let weatherData = self.weatherData ?? WeatherData(weather: [], name: "Test City")
        return Just(weatherData)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

