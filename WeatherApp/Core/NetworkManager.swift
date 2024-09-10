//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Ichsan Indra Wahyudi on 04/09/24.
//

import Combine
import Foundation

class NetworkManager {
    func fetchWeather(_ lat: Double, _ long: Double) -> AnyPublisher<WeatherData, Error> {
        guard let url = URL(string: "\(Constant.API_URL)?lat=\(lat)&lon=\(long)&appid=\(Constant.API_KEY)") else {
            return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
        }
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkError.serverError("Server responded with error.")
                }
                
                return result.data
            }
            .decode(type: WeatherData.self, decoder: jsonDecoder)
            .mapError { error -> NetworkError in
                if let urlError = error as? URLError {
                    return .serverError(urlError.localizedDescription)
                } else if let decodingError = error as? DecodingError {
                    return .serverError("Decoding error: \(decodingError.localizedDescription)")
                } else {
                    return .invalidResponse
                }
            }
            .eraseToAnyPublisher()
    }
}

enum NetworkError: LocalizedError {
    case invalidResponse
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from the server."
        case let .serverError(message):
            return message
        }
    }
}
