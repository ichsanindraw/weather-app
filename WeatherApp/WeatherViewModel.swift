//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import Combine
import UIKit
import WidgetKit

class WeatherViewModel {
    private let networkManager: NetworkManager
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    @Published var state: ViewState<WeatherData> = .loading
    @Published var backgroundImage: UIImage?
    
    init(
        backgroundImage: UIImage? = nil,
        networkManager: NetworkManager = NetworkManager()
    ) {
        self.networkManager = networkManager
        if let backgroundImage {
            self.backgroundImage = backgroundImage
        } else {
            self.backgroundImage = loadBgImageFromUserDefaults()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func loadBgImageFromUserDefaults() -> UIImage? {
        let userDefaults = UserDefaults(suiteName: Constant.appGroup)
        
        guard let imageData = userDefaults?.data(forKey: Constant.backgroundImageKey) else {
            return nil
        }
        
        return UIImage(data: imageData)
    }
    
    private func fetchWeather(lat: Double, long: Double) {
        networkManager.fetchWeather(lat, long)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    self?.state = .error(error.localizedDescription)
                }

            }, receiveValue: { [weak self] data in
                self?.state = .success(data)
                self?.storeWeatherData(data)
            })
            .store(in: &cancellables)
    }
    
    func storeWeatherData(_ data: WeatherData) {
        let userDefaults = UserDefaults(suiteName: Constant.appGroup)
        
        if let encodedData = try? JSONEncoder().encode(data) {
            userDefaults?.set(encodedData, forKey: Constant.weatherDataKey)
        }
    }
    
    private func storeBackgroundImage(_ image: UIImage?) {
        let userDefaults = UserDefaults(suiteName: Constant.appGroup)
        
        if let data = image?.pngData() {
            userDefaults?.set(data, forKey: Constant.backgroundImageKey)
        } else {
            userDefaults?.removeObject(forKey: Constant.backgroundImageKey)
        }
    }
    
    func getWeather(lat: Double, long: Double) {
//        if case .loading = state {
            state = .loading
//        }
        
        // Fetch weather data immediately
        fetchWeather(lat: lat, long: long)
        
        // Schedule timer to fetch weather data every 1 minute
//        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { [weak self] _ in
//            self?.fetchWeather(lat: lat, long: long)
//        })
    }
    
    func updateBackgroundImage(_ image: UIImage?) {
        /**
            since we also use the background image for the widget
            and the widget doesn't support for the large images
            we need to resize the image
        */
        
        let resizedImage = image?.resized()
       
        storeBackgroundImage(resizedImage)
        backgroundImage = resizedImage
        
        if #available(iOS 14.0, *) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}
