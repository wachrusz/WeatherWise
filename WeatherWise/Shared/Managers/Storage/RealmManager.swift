//
//  HomeView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import RealmSwift

final class RealmManager {
    static let shared = RealmManager()
    private init() { setupRealm() }

    private func setupRealm() {
        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config
    }

    func saveLocation(_ location: LastLocation) {
        do {
            let realm = try Realm()
            try realm.write {
                if let existing = realm.object(ofType: LastLocation.self, forPrimaryKey: "last_location") {
                    realm.delete(existing)
                }
                realm.add(location)
            }
            print("Location saved: \(location)")
        } catch {
            print("Error saving location: \(error.localizedDescription)")
        }
    }

    func getSavedLocations() -> Results<LastLocation>? {
        do {
            let realm = try Realm()
            return realm.objects(LastLocation.self)
        } catch {
            print("Error fetching saved cities: \(error.localizedDescription)")
            return nil
        }
    }

    func loadSavedLocation() -> LastLocation? {
        guard let savedLocations = getSavedLocations(), !savedLocations.isEmpty else {
            print("No saved location found.")
            return nil
        }
        return savedLocations.first
    }
    
    func saveCachedWeather(_ cachedWeather: CachedWeather) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(cachedWeather, update: .modified)
            }
            print("Saved cached weather: \(cachedWeather.id)")
        } catch {
            print("Error saving cached weather: \(error.localizedDescription)")
        }
    }
    
    func getCachedWeather() -> CachedWeather? {
        do {
            let realm = try Realm()
            if let cachedWeather = realm.objects(CachedWeather.self).sorted(byKeyPath: "timestamp", ascending: false).first {
                print("Loaded cached weather with id: \(cachedWeather.id)")
                return cachedWeather
            }
        } catch {
            print("Error fetching cached weather: \(error.localizedDescription)")
        }
        return nil
    }
    
    func clearCachedWeather() {
        do {
            let realm = try Realm()
            try realm.write {
                let allWeather = realm.objects(CachedWeather.self)
                realm.delete(allWeather)
            }
            print("Cleared all cached weather data.")
        } catch {
            print("Error clearing cached weather data: \(error.localizedDescription)")
        }
    }


}
