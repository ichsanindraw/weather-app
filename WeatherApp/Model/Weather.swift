//
//  Weather.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import Foundation
import UIKit

struct WeatherData: Codable, Equatable {
    let weather: [Weather]
    let name: String
    
    init(weather: [Weather], name: String) {
        self.weather = weather
        self.name = name
    }
}

struct Weather: Codable, Equatable {
    let id: Int
    let main: String
    let description: String
    
    var type: WeatherType {
        return WeatherType(rawValue: main.lowercased()) ?? .unknown
    }
}

enum WeatherType: String {
    case clear
    case clouds
    case drizzle
    case rain
    case thunderstorm
    case snow
    case unknown
    
    var image: UIImage? {
        switch self {
        case .clear:
            return UIImage(named: "sunny")
        case .clouds, .drizzle:
            return UIImage(named: "cloud")
        case .rain, .thunderstorm:
            return UIImage(named: "rain")
        case .snow:
            return UIImage(named: "snow")
        case .unknown:
            return nil
        }
    }
}

// Helper

enum ViewState<T: Equatable>: Equatable {
    case loading
    case success(T)
    case error(String)
}
