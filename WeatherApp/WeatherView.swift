//
//  WeatherView.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import Combine
import UIKit

final class WeatherView: UIView {
    private let collectionView: UICollectionView = {
//        let layout = CenteredFlowLayout()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
//        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
//        view.contentInset = UIEdgeInsets(
//            top: 0, 
//            left: 16,
//            bottom: 0,
//            right: 16
//        )
        view.decelerationRate = .fast
        
        return view
    }()
    
    private let pageControlView: UIPageControl = {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.currentPageIndicatorTintColor = .black
        view.pageIndicatorTintColor = .gray
        return view
    }()
    
    private let totalPages = WeatherCardView.Size.allCases.count
    private var backgroundImage: UIImage?
    private var weatherData: WeatherData?
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        super.init(frame: .zero)
        
        setupCollection()
        setupPageControl()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            WeatherViewCell.self,
            forCellWithReuseIdentifier: WeatherViewCell.cellReuseIdentifier
        )
    }
    
    private func setupPageControl() {
        pageControlView.numberOfPages = totalPages
        pageControlView.addTarget(self, action: #selector(handlePageControlTapped(_ :)), for: .valueChanged)
    }
    
    private func setupUI() {
        addSubview(collectionView)
        addSubview(pageControlView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: pageControlView.topAnchor, constant: -8),
            
            pageControlView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 8),
            pageControlView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControlView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    @objc func handlePageControlTapped(_ sender: UIPageControl) {
        let offsetX = CGFloat(sender.currentPage) * collectionView.frame.size.width
        collectionView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    func didUpdateBackground(_ image: UIImage?) {
        self.backgroundImage = image
        collectionView.reloadData()
    }
    
    func didUpdateData(_ data: WeatherData?) {
        self.weatherData = data
        collectionView.reloadData()
    }
}

extension WeatherView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return WeatherCardView.Size.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherViewCell.cellReuseIdentifier, for: indexPath) as? WeatherViewCell else {
            return UICollectionViewCell()
        }
        
        /// by using this approach, we can easly add another size for the widget in the future
        ///
        cell.configure(
            type: weatherData?.weather.first?.type ?? .unknown,
            size: WeatherCardView.Size.allCases[indexPath.item],
            name: weatherData?.name ?? "",
            withBackground: backgroundImage
        )
        
        // Apply the transform only to the second cell (index 1) when initializing
        if indexPath.item == 1 {
           // Apply any custom transformation
//            cell.transform = CGAffineTransform(translationX: 20, y: 0) // Move the cell by 50 points on the X-axis
           
           // Optionally, you could also apply scaling or other transforms
           // cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2) // Example of scaling
        }
        
        return cell
    }
}

extension WeatherView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index: Double = scrollView.contentOffset.x / collectionView.frame.width
        
        if !index.isNaN {
            pageControlView.currentPage = Int(index)
        }
        
        let visibleCells = collectionView.visibleCells
        
        for cell in visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }
            
            if indexPath.item == 1 {
                let translationX = collectionView.contentOffset.x
                
                let transformValue = translationX / collectionView.bounds.width
                cell.transform = CGAffineTransform(translationX: -transformValue * 50, y: 0)
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
           guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
           
           // Get the width of the cell including spacing
           let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
           
           // Calculate the target offset based on the velocity and the current offset
           let offset = targetContentOffset.pointee.x
           let index = round(offset / cellWidthIncludingSpacing)
           
           // Adjust the final content offset to snap to the center
           let adjustedOffset = index * cellWidthIncludingSpacing
           targetContentOffset.pointee.x = adjustedOffset
       }
}

extension WeatherView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let spacing = (1 / 8) * collectionView.frame.width
        return UIEdgeInsets(
            top: 0,
            left: spacing,
            bottom: 0,
            right: spacing
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return (1.8 / 16) * collectionView.frame.width
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let screenWidth = collectionView.frame.width
//        let visiblePart = screenWidth / 4 // 1/4 part
//        print(">>> screenWidth: \(screenWidth) || visiblePart: \(visiblePart)")
//        
//        return CGSize(width: screenWidth - visiblePart, height: collectionView.frame.height)
        
        let cellWidth = collectionView.bounds.width * 2 / 3 // The cell occupies 2/3 of the screen width
        print(">>> cellWidth: \(cellWidth)")
        return CGSize(width: cellWidth, height: collectionView.bounds.height)
        
//        let cellWidth = (3 / 4) * collectionView.frame.width
//        print(">>> cellWidth: \(cellWidth)")
//        return CGSize(width: cellWidth, height: collectionView.frame.height)
//        return CGSize(width: frame.width / 1.4, height: frame.height)
//        return CGSize(width: frame.width, height: frame.height)
    }
}

//class CarouselCell: UICollectionViewCell {
//    
//    let label: UILabel = {
//        let label = UILabel()
//        label.textAlignment = .center
//        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "LABEL"
//        return label
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        
//        contentView.addSubview(label)
//        contentView.layer.cornerRadius = 10
//        contentView.layer.borderWidth = 2
//        contentView.layer.borderColor = UIColor.gray.cgColor
//        contentView.backgroundColor = .lightGray
//        
//        NSLayoutConstraint.activate([
//            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
//        ])
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

class CenteredFlowLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else { return proposedContentOffset }
        
        // Calculate the size of a single page (cell + spacing)
        let cellWidthIncludingSpacing = itemSize.width + minimumLineSpacing
//        
        print(">>> cellWidthIncludingSpacing: \(cellWidthIncludingSpacing) || proposedContentOffset: \(proposedContentOffset)")
        
        // Calculate the proposed offset after the scrolling
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionView.bounds.size.width / 2
        
        // Get the layout attributes for all visible items in the collection view
        let visibleLayoutAttributes = layoutAttributesForElements(in: collectionView.bounds)
        
        print(">>> proposedContentOffsetCenterX: \(proposedContentOffsetCenterX) || visibleLayoutAttributes: \(visibleLayoutAttributes)")
        
        // Find the closest attribute to the proposed center
        var closestAttribute: UICollectionViewLayoutAttributes?
        for attributes in visibleLayoutAttributes ?? [] {
            if closestAttribute == nil {
                closestAttribute = attributes
                continue
            }
            
            let closestDistance = abs(closestAttribute!.center.x - proposedContentOffsetCenterX)
            let currentDistance = abs(attributes.center.x - proposedContentOffsetCenterX)
            
            if currentDistance < closestDistance {
                closestAttribute = attributes
            }
        }
        
        // Adjust the content offset to center the item
        guard let finalClosestAttribute = closestAttribute else { return proposedContentOffset }
        
        let targetContentOffsetX = finalClosestAttribute.center.x - collectionView.bounds.size.width / 2
        return CGPoint(x: targetContentOffsetX, y: proposedContentOffset.y)
    }
}
