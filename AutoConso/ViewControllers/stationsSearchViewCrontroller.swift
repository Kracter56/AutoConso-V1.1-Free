//
//  stationsSearchViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 18/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import MapKit
import FloatingPanel
import RealmSwift

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class stationsSearchViewCrontroller: UIViewController, FloatingPanelControllerDelegate {
	
	var fpc: FloatingPanelController!

    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
	
    //var coordGPS:CLLocation

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		
		
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
		
//        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
//        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
//        resultSearchController?.searchResultsUpdater = locationSearchTable
//        
//        let searchBar = resultSearchController!.searchBar
//        /*searchBar.sizeToFit()
//        searchBar.placeholder = "Search for places"*/
//        navigationItem.titleView = resultSearchController?.searchBar
//        
//        resultSearchController?.hidesNavigationBarDuringPresentation = false
//        resultSearchController?.dimsBackgroundDuringPresentation = true
//        definesPresentationContext = true
//        
//        locationSearchTable.mapView = mapView
        
        //locationSearchTable.handleMapSearchDelegate = self
        
    }
	
	override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Remove the views managed by the `FloatingPanelController` object from self.view.
		fpc.removePanelFromParent(animated: true)
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Initialize a `FloatingPanelController` object.
		fpc = FloatingPanelController()
		// Assign self as the delegate of the controller.
		fpc.delegate = self
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let contentVC = storyboard.instantiateViewController(withIdentifier: "carsVC") as! CarsViewController
				
		fpc.set(contentViewController: contentVC)

		// Track a scroll view(or the siblings) in the content view controller.
		fpc.track(scrollView: contentVC.tableViewCar)

		// Add and show the views managed by the `FloatingPanelController` object to self.view.
		//        fpc.addPanel(toParent: self)
		fpc.contentMode = .fitToBounds
		fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
		fpc.surfaceView.containerMargins = .init(top: 20.0, left: 16.0, bottom: 16.0, right: 16.0)
		fpc.surfaceView.contentInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
		
		self.present(fpc, animated: true, completion: nil)
	}
	
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
//	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//		let gesture = (gestureRecognizer as! UIPanGestureRecognizer)
//		let direction = gesture.velocity(in: view).y
//
//		let y = view.frame.minY
//		if (y == fullView && tableView.contentOffset.y == 0 && direction > 0) || (y == partialView) {
//			tableView.isScrollEnabled = false
//		} else {
//		  tableView.isScrollEnabled = true
//		}
//
//		return false
//	}
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
}

extension stationsSearchViewCrontroller : CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
			let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
			let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            
            /*self.coordGPS = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)*/
        }
    }
}

/*extension stationsSearchViewCrontroller: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        print("HandleMapSearch : ",placemark.administrativeArea! + " " + placemark.locality!)
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let num = placemark.subThoroughfare, let adresse = placemark.thoroughfare {
            annotation.subtitle = num + " " + adresse + " " + city
        }
        mapView.addAnnotation(annotation)
		let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
}

extension stationsSearchViewCrontroller : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
        button.setBackgroundImage(UIImage(named: "3Dcar"), for: .normal)
        button.addTarget(self, action: #selector(stationsSearchViewCrontroller.getDirections), for: .touchUpInside)
        pinView?.leftCalloutAccessoryView = button
        return pinView
    }
    
    
}*/
