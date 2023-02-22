//
//  NewPlaceViewController.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 01.02.2023.
//

import UIKit

// MARK: - NewPlaceViewController
class NewPlaceViewController: UITableViewController {
    
// MARK: - UI
    @IBOutlet private weak var imageOfPlace: UIImageView!
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var placeName: UITextField!
    @IBOutlet private weak var placeLocation: UITextField!
    @IBOutlet private weak var placeType: UITextField!
    @IBOutlet private var ratingControl: RatingControl!
    
// MARK: - Actions
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
// MARK: - Params
    var currentPlace: Place!
    
    private var isImageChanged = false
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(
            frame: .init(
                x: 0,
                y: 0,
                width: tableView.frame.size.width,
                height: 1
            )
        )
        
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
// MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == .zero {
            let cameraIcon = UIImage(named: "camera")
            let photoLibraryIcon = UIImage(named: "photo")
            
            let actionSheet = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .actionSheet
            )
            
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            
            camera.setValue(cameraIcon, forKey: "image")
            
            let photoAlbum = UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            photoAlbum.setValue(photoLibraryIcon, forKey: "image")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photoAlbum)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
            
        } else {
            view.endEditing(true)
        }
    }
    
// MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              let mapView = segue.destination as? MapViewController
            else { return }
        
        mapView.incomeSegueIdentifier = identifier
        mapView.mapViewControllerDelegate = self
        
        if identifier == "showPlaceOnMap" {
            mapView.place.name = placeName.text!
            mapView.place.location = placeLocation.text
            mapView.place.type = placeType.text
            mapView.place.imageData = imageOfPlace.image?.pngData()
        }
    }
    
// MARK: - Open methods
    func savePlace() {
        let image = isImageChanged ? imageOfPlace.image : UIImage(named: "imagePlaceholder")
        let imageData = image?.pngData()
        
        let newPlace = Place(
            name: placeName.text!,
            location: placeLocation.text,
            type: placeType.text,
            imageData: imageData,
            ratingOfPlace: ratingControl.ratingOfPlace
        )
        
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.ratingOfPlace = newPlace.ratingOfPlace
            }
            
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
// MARK: - Private methods
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            isImageChanged = true
 
            guard let data = currentPlace?.imageData,
                  let image = UIImage(data: data) else { return }
            
            imageOfPlace.image = image
            imageOfPlace.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeLocation.text = currentPlace?.location
            placeType.text = currentPlace?.type
            ratingControl.ratingOfPlace = currentPlace.ratingOfPlace
        }
    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil )
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
}

// MARK: - UITextFieldDelegate
extension NewPlaceViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageOfPlace.image = info[.editedImage] as? UIImage
        imageOfPlace.contentMode = .scaleAspectFill
        imageOfPlace.clipsToBounds = true
        isImageChanged = true
        
        dismiss(animated: true)
    }
}

// MARK: - MapViewControllerDelegate
extension NewPlaceViewController: MapViewControllerDelegate {
    
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}
