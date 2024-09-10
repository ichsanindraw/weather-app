//
//  Constants.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 04/09/24.
//

import Foundation

struct Constant {
    static let API_URL = (Bundle.main.infoDictionary?["API_URL"] as? String) ?? ""
    static let API_KEY = (Bundle.main.infoDictionary?["API_KEY"] as? String) ?? ""
    
    static let appGroup = "group.com.weatherwidget.app"
    static let weatherDataKey = "weatherData"
    static let backgroundImageKey = "weatherBackgroundImage"
}
