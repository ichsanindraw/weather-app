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
    var mockNetworkManager: MockNetworkManager!
    var mockUserDefaults: MockUserDefaults!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        
        mockNetworkManager = MockNetworkManager()
        mockUserDefaults = MockUserDefaults(suiteName: Constant.appGroup)
        
        viewModel = WeatherViewModel(
            networkManager: mockNetworkManager,
            userDefaults: mockUserDefaults
        )
        
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkManager = nil
        cancellables = nil
        
        super.tearDown()
    }
    
    func testInitialStateIsLoading() {
        // Check initial state
        XCTAssertEqual(viewModel.state, .loading, "Initial state should be loading")
    }
    
    func testFetchWeatherSuccess() {
        let mockWeatherData = WeatherData(weather: [], name: "Success City")
        mockNetworkManager.weatherData = mockWeatherData
        
        viewModel.getWeather(lat: 0.0, long: 0.0)
        
        // Expect the state to change to success with the correct data
        let expectation = XCTestExpectation(description: "Weather data fetch should succeed")
        
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .success(let data) = state {
                    XCTAssertEqual(data.name, "Success City", "Weather data should match the mock data")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFetchWeatherFailure() {
        mockNetworkManager.isError = true

        viewModel.getWeather(lat: 0.0, long: 0.0)
       
        let expectation = XCTestExpectation(description: "Weather data fetch should fail")
       
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .error(let message) = state {
                    XCTAssertEqual(message, URLError(.badServerResponse).localizedDescription, "Error message should match")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
       
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testUpdateBackgroundImage() {
        let mockImage = UIImage(systemName: "sun")
        
        viewModel.updateBackgroundImage(mockImage)
        
        XCTAssertEqual(viewModel.backgroundImage, mockImage?.resized(), "Background image should be resized and set")
    }
    
    func testStoreWeatherData() {
        let mockWeatherData = WeatherData(weather: [], name: "Stored City")
            
        viewModel.storeWeatherData(mockWeatherData)
            
        if let encodedData = mockUserDefaults.storedData[Constant.weatherDataKey] as? Data {
           let decodedWeatherData = try? JSONDecoder().decode(WeatherData.self, from: encodedData)
           XCTAssertEqual(decodedWeatherData, mockWeatherData)
       } else {
           XCTFail("Weather data was not saved correctly.")
       }
    }
    
    func testStoreBackgroundImage() {
        let mockImage = UIImage(systemName: "sun")
            
        viewModel.storeBackgroundImage(mockImage)
            
        if let storedImageData = mockUserDefaults.storedData[Constant.backgroundImageKey] as? Data,
           let imageData = mockImage?.pngData() {
            XCTAssertEqual(storedImageData, imageData)
        } else {
            XCTFail("Background image was not saved correctly.")
        }
    }
    
    func testRemoveStoredBackgroundImage() {
        mockUserDefaults.storedData[Constant.backgroundImageKey] = Data()
        
        viewModel.storeBackgroundImage(nil)
        
        XCTAssertNil(mockUserDefaults.storedData[Constant.backgroundImageKey], "Background image was not removed correctly.")
    }
}
