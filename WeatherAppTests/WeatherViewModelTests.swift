//
//  WeatherViewModelTests.swift
//  WeatherAppTests
//
//  Created by Ichsan Indra Wahyudi on 05/09/24.
//

import Combine
import XCTest

@testable import WeatherApp

final class WeatherViewModelTests: XCTestCase {
    var viewModel: WeatherViewModel!
    var networkManager: MockNetworkManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        
        networkManager = MockNetworkManager()
        viewModel = WeatherViewModel(networkManager: networkManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        networkManager = nil
        cancellables = nil
        
        super.tearDown()
    }
    
    func testGetWeather_ShouldCallFetchWeather() {
        let expectedWeatherData = WeatherData.mock
        networkManager.weatherDataToReturn = expectedWeatherData

        viewModel.getWeather(lat: 37.7749, long: -122.4194)

        XCTAssertTrue(networkManager.fetchWeatherCalled, "fetchWeather should have been called")
        
        let expectation = XCTestExpectation(description: "Weather data should be updated")
        viewModel.$weatherData
            .sink { weatherData in
                XCTAssertEqual(weatherData, expectedWeatherData)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateBackgroundImage_ShouldStoreImage() {
        let testImage = UIImage(systemName: "test_image")

        viewModel.updateBackgroundImage(testImage)

        XCTAssertNotNil(viewModel.backgroundImage, "Background image should be updated")
        
        // Verify the image was stored in UserDefaults
        let userDefaults = UserDefaults(suiteName: Constant.appGroup)
        XCTAssertNotNil(userDefaults?.data(forKey: Constant.backgroundImageKey), "Image should be saved in UserDefaults")
    }
    
    func testLoadBgImageFromUserDefaults_ShouldLoadImage() {
        let testImage = UIImage(systemName: "sun.max")
        let userDefaults = UserDefaults(suiteName: Constant.appGroup)
        userDefaults?.set(testImage?.pngData(), forKey: Constant.backgroundImageKey)

        let loadedImage = viewModel.backgroundImage

        XCTAssertNotNil(loadedImage, "Background image should be loaded from UserDefaults")
    }

    func testStoreWeatherData_ShouldSaveToUserDefaults() {
        let weatherData = WeatherData.mock

        viewModel.storeWeatherData(weatherData)

        let userDefaults = UserDefaults(suiteName: Constant.appGroup)
        let storedData = userDefaults?.data(forKey: Constant.weatherDataKey)
        XCTAssertNotNil(storedData, "Weather data should be saved to UserDefaults")
    }

}
