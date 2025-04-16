//
//  HomeView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import Combine
import MapKit

final class SearchViewModel: NSObject, ObservableObject {
    @Published var query = ""
    @Published var results = [MKLocalSearchCompletion]()
    @Published var isLoading = false
    @Published var error: SearchError?
    
    private let completer = MKLocalSearchCompleter()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupSearch()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
        checkLocationAuthorization()
    }
    
    private func setupSearch() {
        $query
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.completer.queryFragment = query
                if query.isEmpty {
                    self?.results = []
                }
            }
            .store(in: &cancellables)
    }
    
    func selectCompletion(_ completion: MKLocalSearchCompletion) {
        isLoading = true
        
        let request = MKLocalSearch.Request(completion: completion)
        print("request: \(request)")
        request.region = SharedLocationData.shared.selectedRegion
        print(request.region)
        
        MKLocalSearch(request: request).start { [weak self] response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = .searchFailed(error.localizedDescription)
                    return
                }
                
                guard let item = response?.mapItems.first else {
                    self?.error = .noResults
                    return
                }
                
                SharedLocationData.shared.moveToLocation(
                    item.placemark.coordinate,
                    spanDelta: 0.02
                )
            }
        }
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            error = .locationAccessDenied
        default:
            break
        }
    }
}

extension SearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
            .filter { !$0.title.isEmpty }
            .sorted(by: { $0.title < $1.title })
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.error = .completerFailed(error.localizedDescription)
    }
}

enum SearchError: LocalizedError {
    case searchFailed(String)
    case noResults
    case locationAccessDenied
    case completerFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .searchFailed(let message): return "Ошибка поиска: \(message)"
        case .noResults: return "Ничего не найдено"
        case .locationAccessDenied: return "Доступ к геолокации запрещен"
        case .completerFailed(let message): return "Ошибка автодополнения: \(message)"
        }
    }
}
