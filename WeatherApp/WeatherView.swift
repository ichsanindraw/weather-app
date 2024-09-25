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
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        setupCollection()
        setupPageControl()
        setupUI()
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
        collectionView.scrollToItem(at: IndexPath(item:  sender.currentPage, section: 0), at: .centeredHorizontally, animated: true)
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
        
        return cell
    }
}

extension WeatherView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells = collectionView.visibleCells
        
        for cell in visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else {
                continue
            }
            
            if indexPath.item == 0 {
                let translationX = collectionView.contentOffset.x
                
                let transformValue = translationX / collectionView.bounds.width
                cell.transform = CGAffineTransform(translationX: transformValue * 96, y: 0)
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerNearestVisibleCell()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerNearestVisibleCell()
    }

    private func centerNearestVisibleCell() {
        // Find the visible cells
        let visibleCells = collectionView.visibleCells
        
        // If there are no visible cells, return
        guard !visibleCells.isEmpty else { return }
        
        // Assume the first cell is the closest one
        var closestCell = visibleCells[0]
        
        // Find the center point of the collection view's visible area
        let collectionViewCenter = collectionView.bounds.size.width / 2.0 + collectionView.contentOffset.x
        
        // Iterate through all visible cells to find the closest to the center
        for cell in visibleCells {
            let closestCellDelta = abs(closestCell.center.x - collectionViewCenter)
            let cellDelta = abs(cell.center.x - collectionViewCenter)
            
            // If the current cell is closer, update the closest cell
            if cellDelta < closestCellDelta {
                closestCell = cell
            }
        }
        
        // Get the index path of the closest cell and scroll to it
        if let indexPath = collectionView.indexPath(for: closestCell) {
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            pageControlView.currentPage = Int(indexPath.item)
        }
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
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let visiblePart = screenWidth / 4
        
        return CGSize(width: screenWidth - visiblePart, height: collectionView.frame.height)
    }
}
