//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 29.01.2023.
//

import Foundation


struct Place {
    
    var name: String
    var location: String
    var type: String
    var image: String
    
    static let restarauntNames = [
        "Tom Yum Bar", "Сыроварня", "Коробок", "Мятный карась",
        "Перчини", "Аджикинежаль", "Шашлыкофф",
        "KFC", "Burger King", "Carlos Junior", "Русские блины",
        "Якитория", "Panda Chef", "Nemo", "Cinnabon"
    ]
    
    static func getPlaces() -> [Place] { // static чтобы метод был доступен при обращении к самой структуре
        var places = [Place]()
        for place in restarauntNames {
            places.append(Place(name: place, location: "Новосибирск", type: "Ресторан", image: place))
        }
        
        return places
    }
}
