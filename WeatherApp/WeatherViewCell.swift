//
//  WeatherViewCell.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import UIKit

final class WeatherViewCell: UICollectionViewCell {
    private var cardView: WeatherCardView?
    
    static let cellReuseIdentifier  = String(describing: WeatherViewCell.self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        contentView.backgroundColor = .systemRed
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cardView?.removeFromSuperview()
        cardView = nil
    }
    
    func configure(
        type: WeatherType,
        size: WeatherCardView.Size,
        name: String,
        withBackground image: UIImage?
    ) {
        cardView = WeatherCardView(
            type: type,
            size: size,
            name: name,
            backgroundImage: image
        )
        
        if let cardView {
            contentView.addSubview(cardView)
            
            NSLayoutConstraint.activate([
                cardView.centerXAnchor.constraint(equalTo: centerXAnchor),
                cardView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
            
            switch size {
            case .small:
                NSLayoutConstraint.activate([
                    cardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
                    cardView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
                ])
            case .medium:
                NSLayoutConstraint.activate([
                    cardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
                    cardView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
                ])
            case .large:
                NSLayoutConstraint.activate([
                    cardView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
                    cardView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0)
                ])
            }
        }
        
        print(">>> card size: \(size) || \(self.frame)")
    }
}
