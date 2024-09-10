//
//  ButtonView.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import UIKit

final class ButtonView: UIButton {
    enum `Type` {
        case main
        case danger
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: 50)
    }
    
    init(title: String, type: ButtonView.`Type`) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        
        layer.cornerRadius = 24
        
        switch type {
        case .main:
            backgroundColor = UIColor.accentGreen
        case .danger:
            backgroundColor = UIColor.accentRed
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


