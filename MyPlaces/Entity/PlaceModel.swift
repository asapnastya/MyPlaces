//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 29.01.2023.
//

import RealmSwift

// MARK: - Place
class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date()
    @objc dynamic var ratingOfPlace = 0 

// MARK: - init
    convenience init(name: String, location: String?, type: String?, imageData: Data?, ratingOfPlace: Int) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.ratingOfPlace = ratingOfPlace
    }
}
