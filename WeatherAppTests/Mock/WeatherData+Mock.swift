//
//  WeatherData+Mock.swift
//  WeatherAppTests
//
//  Created by Ichsan Indra Wahyudi on 05/09/24.
//

@testable import WeatherApp

extension WeatherData {
    static let mock = WeatherData(
        weather: [
            Weather.mockSunny
        ],
        name: "Jakarta"
    )
}

extension Weather {
    static let mockSunny = Weather(
        id: 1,
        main: "Clear",
        description: "clear"
    )
}
