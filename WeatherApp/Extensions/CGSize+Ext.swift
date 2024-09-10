//
//  CGSize+Ext.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import Foundation

extension CGSize {
    static func square(size: CGFloat) -> Self {
        return CGSize(width: size, height: size)
    }
}
