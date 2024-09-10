//
//  MainViewController.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 03/09/24.
//

import Combine
import CoreLocation
import UIKit

final class MainViewController: UIViewController {
    private let shimmerView: ShimmerView = {
        let view = ShimmerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let widgetView: WeatherView = {
        let view = WeatherView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let changeBgButtonView: ButtonView = {
        let view = ButtonView(title: "Change Background", type: .main)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let resetBgButtonView: ButtonView = {
        let view = ButtonView(title: "Reset Background", type: .danger)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var pickerView: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    private let locationManager = CLLocationManager()
    
    private let padding: CGFloat = 16
    private let viewModel = WeatherViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.lightSand
        title = "Weather Widget"
        
        setupNavigationAppearance()
        bindViewModel()
      
        pickerView.delegate = self
        locationManager.delegate = self
        
        let isSetup: Bool
        
        if #available(iOS 14.0, *) {
            isSetup = checkPermission(status: locationManager.authorizationStatus)
        } else {
            isSetup = checkPermission(status: CLLocationManager.authorizationStatus())
        }
            
        if isSetup {
//            setupLoadingLayout()
        }
        
        if let location = locationManager.location {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            viewModel.getWeather(lat: lat, long: long)
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func setup() {
        setupSuccessLayout()
        setupAction()
    }

    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupLoadingLayout() {
        widgetView.removeFromSuperview()
        changeBgButtonView.removeFromSuperview()
        resetBgButtonView.removeFromSuperview()
        
        view.addSubview(shimmerView)
        
        NSLayoutConstraint.activate([
            shimmerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shimmerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            shimmerView.widthAnchor.constraint(equalToConstant: 150),
            shimmerView.heightAnchor.constraint(equalToConstant: 150)
        ])
    }
    
    private func setupSuccessLayout() {
        shimmerView.removeFromSuperview()
        
        view.addSubview(widgetView)
        view.addSubview(changeBgButtonView)
        view.addSubview(resetBgButtonView)
        
        NSLayoutConstraint.activate([
            widgetView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            widgetView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            widgetView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            widgetView.bottomAnchor.constraint(equalTo: changeBgButtonView.topAnchor, constant: -padding),
            
            changeBgButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            changeBgButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            changeBgButtonView.bottomAnchor.constraint(equalTo: resetBgButtonView.topAnchor, constant: -padding),
            
            resetBgButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            resetBgButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            resetBgButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -padding)
        ])
    }
    
    private func setupAction() {
        changeBgButtonView.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        resetBgButtonView.addTarget(self, action: #selector(resetBackground), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                print(">>> handleState: \(state)")
                self?.handleState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$backgroundImage
            .sink { [weak self] image in
                self?.widgetView.didUpdateBackground(image)
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ viewState: ViewState<WeatherData>) {
        switch viewState {
        case .loading:
            shimmerView.isHidden = false
            setupLoadingLayout()
            
        case let .success(data):
            setupSuccessLayout()
            widgetView.didUpdateData(data)
            
        case let .error(message):
            shimmerView.isHidden = true
            showErrorAlert(message: message)
        }
    }
    
    @objc private func openGallery() {
        /// we are using `UIImagePicker` for support earliest version due to the target version is from iOS 13.0
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return
        }
        
        present(pickerView, animated: true)
    }
    
    @objc private func resetBackground() {
        viewModel.updateBackgroundImage(nil)
    }
    
    private func checkPermission(status: CLAuthorizationStatus) -> Bool {
        switch status {
        case .restricted, .denied:
            showPermissionDeniedAlert()
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Access Needed",
            message: "To continue using all features of the app, please enable location permissions in Settings.",
            preferredStyle: .alert
        )
       
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
            }
        }))
       
       present(alert, animated: true, completion: nil)
   }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Network Request Failed",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] _ in
            guard let self, let location = locationManager.location else {
                return
            }
            
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            self.viewModel.getWeather(lat: lat, long: long)
        }))
       
        present(alert, animated: true, completion: nil)
   }
}

extension MainViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.updateBackgroundImage(image)
        }
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        
        switch status {
        case .notDetermined:
            print(">>> notDetermined")
        case .restricted, .denied:
            showPermissionDeniedAlert()
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            setupLoadingLayout()
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else {
            return
        }
        
        let lat = lastLocation.coordinate.latitude
        let long = lastLocation.coordinate.longitude
        
        viewModel.getWeather(lat: lat, long: long)
    }
}
