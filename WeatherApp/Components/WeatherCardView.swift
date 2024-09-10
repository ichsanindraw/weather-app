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
        
//        internal var preferredSize: CGSize {
//            switch self {
//            case .small:
//                return CGSize.square(size: 155)
//            case .medium:
//                return CGSize(width: 329, height: 155)
//            case .large:
//                return CGSize(width: 329, height: 345)
//            }
//        }
        
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
        
        let angleInRadians = 5 * CGFloat.pi / 180
//        transform = CGAffineTransform(rotationAngle: angleInRadians)
        
//        start3DRotationAnimation()
//        startCubicKeyframeAnimation()
//        performWidgetSelectionAnimation()
//        performWidgetSelectionAnimationWith3D()
//        startInfinitePulsating()
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

        
//        switch size {
//        case .small:
//            NSLayoutConstraint.activate([
//                widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
//                heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0)
////                heightAnchor.constraint(equalToConstant: size.preferredSize.height)
//            ])
//        case .medium:
//            NSLayoutConstraint.activate([
////                widthAnchor.constraint(equalToConstant: size.preferredSize.width),
////                heightAnchor.constraint(equalToConstant: size.preferredSize.height)
//                widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0),
//                heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5)
//            ])
//        case .large:
//            NSLayoutConstraint.activate([
////                widthAnchor.constraint(equalToConstant: size.preferredSize.width),
////                heightAnchor.constraint(equalToConstant: size.preferredSize.height)
//                widthAnchor.constraint(equalTo: widthAnchor, multiplier: 2.0),
//                heightAnchor.constraint(equalTo: widthAnchor, multiplier: 2.0)
//            ])
//        }
        
        print(">>> card frame: \(frame)")
//        
//        if let widthConstraint = constraints.first(where: {
//            $0.firstAttribute == .width
//        }) {
//            print("Width Constraint Multiplier: \(widthConstraint.multiplier)")
//        }
    }
    
    private func start3DRotationAnimation() {
        var perspective = CATransform3DIdentity
        perspective.m34 = -1.0 / 500.0 // Adding perspective

//        layer.transform = perspective

        let rotationX = CABasicAnimation(keyPath: "transform.rotation.x")
        rotationX.fromValue = 0
        rotationX.toValue = CGFloat.pi * 2 // 360 degrees

//        let rotationY = CABasicAnimation(keyPath: "transform.rotation.y")
//        rotationY.fromValue = 0
//        rotationY.toValue = CGFloat.pi * 2 // 360 degrees

        let group = CAAnimationGroup()
//        group.animations = [rotationX, rotationY]
        group.animations = [rotationX]
        group.duration = 3
        group.repeatCount = .infinity

        layer.add(group, forKey: "3DRotation")
    }
    
    private func startCubicKeyframeAnimation() {
        UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: [.calculationModeCubic], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(rotationAngle: .pi)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.transform = CGAffineTransform(translationX: 0, y: 200)
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.transform = .identity
            }
        })
    }
    
    private func performWidgetSelectionAnimation() {
       // Start the animation with scaling and rotation
       UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
           // Scale down and rotate slightly
           self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9).rotated(by: .pi / 12)
       }) { _ in
           // Expand with a bounce effect
           UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [], animations: {
               // Scale back up, rotate back to normal
               self.transform = CGAffineTransform.identity
           }, completion: nil)
       }
   }
    
    private func performWidgetSelectionAnimationWith3D() {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0 // Perspective
        transform = CATransform3DRotate(transform, .pi / 8, 1, 0, 0) // 3D rotation

        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .repeat], animations: {
            self.layer.transform = transform
        }) { _ in
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.repeat], animations: {
                self.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    private func startInfinitePulsating() {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: [.repeat, .autoreverse],
                       animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }, completion: nil)
    }
}
