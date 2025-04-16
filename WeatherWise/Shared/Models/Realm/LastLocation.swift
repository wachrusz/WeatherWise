//
//  Realm.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import RealmSwift

final class SavedCity: Object {
    @Persisted var name: String
    @Persisted var lat: Double
    @Persisted var lon: Double
}  
