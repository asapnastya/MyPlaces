//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 27.01.2023.
//

import UIKit
import Cosmos

// MARK: - CustomTableViewCell
class CustomTableViewCell: UITableViewCell {

// MARK: - UI
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
}
