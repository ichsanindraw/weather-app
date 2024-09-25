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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(title: String, type: ButtonView.`Type`) {
        self.init(frame: .zero)
        
        configure(title: title, type: type)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configure(title: String, type: ButtonView.`Type`) {
        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        setTitleColor(.white, for: .highlighted)
        
        layer.cornerRadius = 24
        
        switch type {
        case .main:
            backgroundColor = UIColor.accentGreen
        case .danger:
            backgroundColor = UIColor.accentRed
        }
    }
}


