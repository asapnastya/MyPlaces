//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 03.02.2023.
//

import RealmSwift

let realm = try! Realm()

// MARK: - StorageManager
class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
}
