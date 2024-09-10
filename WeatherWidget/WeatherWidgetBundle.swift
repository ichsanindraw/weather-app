//
//  WeatherWidgetBundle.swift
//  WeatherWidget
//
//  Created by Ichsan Indra Wahyudi on 04/09/24.
//

import WidgetKit
import SwiftUI

@main
struct WeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        WeatherWidget()
        WeatherWidgetLiveActivity()
    }
}
