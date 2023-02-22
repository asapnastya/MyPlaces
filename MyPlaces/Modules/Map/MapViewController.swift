//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Анастасия Романова on 2/14/23.
//

import UIKit
import MapKit
import CoreLocation

// MARK: - MapViewControllerDelegate
protocol MapViewControllerDelegate {
    
    func getAddress(_ address: String?)
}

// MARK: - MapViewController
class MapViewController: UIViewController {
    
// MARK: - UI
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var mapPinImage: UIImageView!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var goButton: UIButton!
    
// MARK: - Params
    let mapManager = MapManager()
    let annotationIdentifier = String.annotationIdentifier
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var incomeSegueIdentifier = ""
        
    private var previousUserLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                previousUserLocation: previousUserLocation) { (currentLocation) in
                self.previousUserLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
// MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        setupMapView()
    }
    
// MARK: - Actions
    @IBAction private func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction private func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction private func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousUserLocation = location
        }
    }
    
    @IBAction private func closeMap() {
        dismiss(animated: true)
    }
    
// MARK: - Private functions
    private func setupMapView() {
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }

        if incomeSegueIdentifier == "showPlaceOnMap" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(
                annotation: annotation,
                reuseIdentifier: annotationIdentifier
            )
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterMapLocation(for: mapView)
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == "showPlaceOnMap" && previousUserLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
        
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let numberOfBuilding = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && numberOfBuilding != nil {
                    self.addressLabel.text = "\(streetName!), \(numberOfBuilding!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer =  MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ){
        mapManager.checkLocationAuthorization(
            mapView: mapView,
            segueIdentifier: incomeSegueIdentifier
        )
    }
}

// MARK: - String
private extension String {
    static let annotationIdentifier = "annotationIdentifier"
}
