//
//  RootViewController.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 11/09/24.
//

import Combine
import CoreLocation
import UIKit

/**
 setup UI using Storyboard
*/

final class RootViewController: UIViewController {
    
    @IBOutlet weak var shimmerView: ShimmerView!
    @IBOutlet weak var weatherView: WeatherView!
    
    @IBOutlet weak var changeBgButtonView: ButtonView!
    @IBOutlet weak var resetBgButtonView: ButtonView!
    
    private lazy var pickerView: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        return picker
    }()
    
    private let locationManager = CLLocationManager()
    private let viewModel = WeatherViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Weather Widget"
        
        changeBgButtonView.configure(title: "Change Background", type: .main)
        resetBgButtonView.configure(title: "Reset Background", type: .danger)
        
        setupNavigationAppearance()
        bindViewModel()
        
        pickerView.delegate = self
        locationManager.delegate = self
        
        if #available(iOS 14.0, *) {
            checkPermission(status: locationManager.authorizationStatus)
        } else {
            checkPermission(status: CLLocationManager.authorizationStatus())
        }
        
        if let location = locationManager.location {
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            viewModel.getWeather(lat: lat, long: long)
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    private func setupNavigationAppearance() {
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func bindViewModel() {
        viewModel.$state
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.handleState(state)
            }
            .store(in: &cancellables)
        
        viewModel.$backgroundImage
            .sink { [weak self] image in
                self?.weatherView.didUpdateBackground(image)
            }
            .store(in: &cancellables)
    }
    
    private func handleState(_ viewState: ViewState<WeatherData>) {
        switch viewState {
        case .loading:
            shimmerView.isHidden = false
            weatherView.isHidden = true
            changeBgButtonView.isHidden = true
            resetBgButtonView.isHidden = true
            
        case let .success(data):
            shimmerView.isHidden = true
            weatherView.isHidden = false
            changeBgButtonView.isHidden = false
            resetBgButtonView.isHidden = false
            
            weatherView.didUpdateData(data)
            
        case let .error(message):
            shimmerView.isHidden = true
            showErrorAlert(message: message)
        }
    }
    
    private func checkPermission(status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            showPermissionDeniedAlert()
        default:
            break
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

    @IBAction func handleChangeBackground(_ sender: UIButton) {
        /// we are using `UIImagePicker` for support earliest version due to the target version is from iOS 13.0
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            return
        }
        
        present(pickerView, animated: true)
    }
    
    @IBAction func handleResetBackground(_ sender: UIButton) {
        viewModel.updateBackgroundImage(nil)
    }
}

extension RootViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension RootViewController: CLLocationManagerDelegate {
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
