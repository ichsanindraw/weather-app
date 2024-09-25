//
//  WeatherCardView.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import UIKit

final class WeatherCardView: UIView {
    enum Size: CaseIterable {
        case small
        case medium
        case large
        
        internal var imageSize: CGSize {
            switch self {
            case .small:
                return CGSize.square(size: 67)
            case .medium:
                return CGSize.square(size: 82)
            case .large:
                return CGSize.square(size: 155)
            }
        }
        
        internal var fontSize: CGFloat {
            switch self {
            case .small:
                return 18
            case .medium:
                return 22
            case .large:
                return 32
            }
        }
    }
    
    private let backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let labelView: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 2
        return view
    }()
    
    private let cornerRadius: CGFloat = 22
    private let padding: CGFloat = 16
    private let size: WeatherCardView.Size
    
    init(
        type: WeatherType,
        size: WeatherCardView.Size,
        name: String,
        backgroundImage image: UIImage?
    ) {
        self.size = size
        
        super.init(frame: .zero)
        
        imageView.image = type.image
        labelView.text = name
        labelView.textColor = image != nil ? .white :  .black
        backgroundImageView.image = image
        
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 4)
        layer.shadowRadius = 16
        
        backgroundImageView.layer.cornerRadius = cornerRadius
        labelView.font = UIFont.systemFont(ofSize: size.fontSize)
        
        animateWidget3D()
    }
    
    private func setupLayout() {
        addSubview(backgroundImageView)
        addSubview(imageView)
        addSubview(labelView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: labelView.topAnchor, constant: -10),
            imageView.widthAnchor.constraint(equalToConstant: size.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: size.imageSize.height),
            
            labelView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            labelView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            labelView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }
    
    private func animateWidget3D() {
        let rotationAngle: CGFloat = 0.2
        
        UIView.animate(withDuration: 4.0, delay: 0, options: [.autoreverse, .repeat], animations: {
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500.0
            
            transform = CATransform3DRotate(transform, rotationAngle, 0, 1, 0)
            transform = CATransform3DRotate(transform, rotationAngle, 1, 0, 0)
            
            self.layer.transform = transform
            
        }, completion: nil)
    }
}
