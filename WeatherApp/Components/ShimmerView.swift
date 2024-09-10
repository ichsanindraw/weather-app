//
//  ShimmerView.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 09/09/24.
//

import UIKit

final class ShimmerView: UIView {

    private var gradientLayer: CAGradientLayer?

    override func layoutSubviews() {
        super.layoutSubviews()
        setupShimmer()
    }

    private func setupShimmer() {
        // Remove any previous gradient layer if exists
        gradientLayer?.removeFromSuperlayer()
        
        // Create the gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        
        // Colors for the shimmer animation
        gradientLayer.colors = [
            UIColor(white: 0.85, alpha: 1.0).cgColor,
            UIColor(white: 0.75, alpha: 1.0).cgColor,
            UIColor(white: 0.85, alpha: 1.0).cgColor
        ]
        
        // Define the start and end points of the gradient
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Set locations to move the gradient for shimmer effect
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.cornerRadius = 12
        
        self.layer.addSublayer(gradientLayer)
        
        // Add animation to the gradient layer
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        
        gradientLayer.add(animation, forKey: "shimmerAnimation")
        
        // Keep a reference to the gradient layer to remove or update it later
        self.gradientLayer = gradientLayer
    }
    
    // Function to stop the shimmer animation
    func stopShimmer() {
        gradientLayer?.removeFromSuperlayer()
        gradientLayer = nil
    }
}
