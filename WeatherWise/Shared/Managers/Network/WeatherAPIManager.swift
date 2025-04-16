//
//  HomeView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import Combine
import SwiftyJSON
import CoreLocation

final class WeatherAPIManager {
    static let shared = WeatherAPIManager()
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = true
        configuration.multipathServiceType = .handover
        
        self.session = URLSession(configuration: configuration)
    }
    
    func fetchWeather(location: CLLocation?,completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        guard let location else{
            completion(.failure(URLError(.badServerResponse)))
            return
        }
        
        let urlString = "\(Constants.baseURL)weather?lat=\(location.coordinate.latitude)&lon=\(location.coordinate.longitude)&api_key=\(Constants.weatherAPIKey)"
        
        guard let url = URL(string: urlString) else {
            logError("Invalid URL: \(urlString)")
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("WeatherWise/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        
        logRequest(request: request)
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                self?.logError("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self?.logError("Invalid response type")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            self?.logResponse(response: httpResponse, data: data)
            
            guard 200..<300 ~= httpResponse.statusCode else {
                self?.logError("Bad status code: \(httpResponse.statusCode)")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data else {
                self?.logError("Empty response data")
                completion(.failure(URLError(.zeroByteResource)))
                return
            }
            
            do {
                self?.logJSON(data: data)
                
                let decoder = JSONDecoder()
                let response = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(response))
            } catch {
                self?.logError("Decoding failed: \(error)")
                self?.logDecodingError(error, data: data)
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Логирование
    private func logRequest(request: URLRequest) {
        print("""
        ⚡️ Request:
        URL: \(request.url?.absoluteString ?? "nil")
        Method: \(request.httpMethod ?? "nil")
        Headers: \(request.allHTTPHeaderFields ?? [:])
        """)
    }
    
    private func logResponse(response: HTTPURLResponse, data: Data?) {
        print("""
        🔥 Response:
        Status Code: \(response.statusCode)
        Headers: \(response.allHeaderFields)
        Data Size: \(data?.count ?? 0) bytes
        """)
    }
    
    private func logJSON(data: Data) {
        do {
            let json = try JSON(data: data)
            print("📄 JSON Response:")
            print(json)
        } catch {
            print("❌ Failed to parse JSON: \(error)")
        }
    }
    
    private func logDecodingError(_ error: Error, data: Data) {
        print("""
        🛑 Decoding Error:
        Type: \(type(of: error))
        Message: \(error.localizedDescription)
        Raw Data (first 200 chars):
        \(String(data: data, encoding: .utf8)?.prefix(200) ?? "Invalid data")
        """)
    }
    
    private func logError(_ message: String) {
        print("⛔️ [ERROR] \(message)")
    }
}
