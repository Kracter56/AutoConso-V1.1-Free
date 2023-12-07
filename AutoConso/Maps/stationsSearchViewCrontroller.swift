//
//  stationsSearchViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 18/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import MapKit
import GeoQueries
import RealmSwift
import CoreLocation
import FloatingPanel
import GoogleMobileAds
import PersonalizedAdConsent
import CWProgressHUD
import Firebase
import FirebaseDatabase

protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MyButton : UIButton {
    //var annotation: CustomPointAnnotation? = nil
}

struct Stadium {
  var name: String
  var lattitude: CLLocationDegrees
  var longtitude: CLLocationDegrees
}

class stationsSearchViewCrontroller: UIViewController, MKMapViewDelegate, GADBannerViewDelegate {
	
	var fpc: FloatingPanelController!
	var stationObj:stationObject?
	var oStation:stationsBDD?
	var listeStationsBDD = [stationsBDD]()
	var listeStations = [stationObject]()
    var selectedPin:MKPlacemark? = nil
    let locationManager = CLLocationManager()
    var resultSearchController:UISearchController? = nil
	var myPosition:CLLocationCoordinate2D?
	var stationPosition:CLLocationCoordinate2D?
    //var coordGPS:CLLocation
	var cguAccept:Bool = false
    var bannerView: GADBannerView!
    var langue = ""
    var realm:Realm?
	var consentState:Int = 0
	var usrCountry:String?
	var mklocalSearchRequest:MKLocalSearch.Request?
	var mklocalSearch:MKLocalSearch?
	var myLocation:CLLocation?
	var matchingItems:[MKMapItem] = []

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

		
        // Do any additional setup after loading the view.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
		CWProgressHUD.show(withMessage: textStrings.strChargement)
		
		if CLLocationManager.locationServicesEnabled() {
		   // continue to implement here
		} else {
		   // Do something to let users know why they need to turn it on.
			checkAuthorizationStatus()
		}
		
		Utility.getUserInformation()
		print("profil = "+Utility.userProfile!)
		if(Utility.userProfile != "admin"){
			if let tabBarItem = self.tabBarController?.tabBar.items?[3] as? UITabBarItem {
				tabBarItem.isEnabled = false
			}
			print("desactivation mode admin")
		}else{
			if let tabBarItem = self.tabBarController?.tabBar.items?[3] as? UITabBarItem {
				tabBarItem.isEnabled = true
			}
			print("activation mode admin")
		}
		
		let settings = UserDefaults.standard
		self.usrCountry = settings.string(forKey: "usrCountry")
        self.cguAccept = settings.bool(forKey: "cguAccept")
        
        if(self.cguAccept == false){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "cgu_screen") as! CGUViewController
        
            self.present(destinationViewController, animated: true, completion: {
                self.loadAds()
            })
        }
		

    }
    
    @objc func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
	func checkAuthorizationStatus() {
	  switch CLLocationManager.authorizationStatus() {
		case .authorizedWhenInUse: break
		case .denied: break
		case .notDetermined: break
		case .restricted: break
		case .authorizedAlways: break
	  }
	}
	
	// Here we add disclosure button inside annotation window
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView{
            print(view.annotation!.title) // annotation's title
            print(view.annotation!.subtitle) // annotation's subttitle
			let id = view.annotation!.subtitle
			print("selected station = %@",id)
			if(self.fpc != nil){
				self.fpc.dismiss(animated: true)
			}
			
			
			self.stationObj = nil
				
			for oStation in self.listeStations{
				if(oStation.idStation == id){
					self.stationObj = oStation
				}
			}
//			let realm = try! Realm()
//			self.oStation = realm.objects(stationsBDD.self).filter("idStation = %@",id).first
//
//			self.stationObj = stationObject(idStation: oStation!.idStation, nom: oStation!.nomStation, marque: oStation!.marque, adresse: oStation!.adresse, codePostal: oStation!.codePostal.description, ville: oStation!.ville, distance: "", latitude: oStation!.latitude, longitude: oStation!.longitude, services: oStation!.services.joined(separator: ", "), prixEssPlus: "", majEssPlus: "", ruptureEssPlus: "", prixSP95E10: "", majSP95E10: "", ruptureSP95E10: "", prixSP95: "", majSP95: "", ruptureSP95: "", prixSP98: "", majSP98: "", ruptureSP98: "", prixSUPER: "", majSUPER: "", ruptureSUPER: "", prixDieselPlus: "", majDieselPlus: "", ruptureDieselPlus: "", prixDiesel: "", majDiesel: "", ruptureDiesel: "", prixGPL: "", majGPL: "", ruptureGPL: "", prixEthanol: "", majEthanol: "", ruptureEthanol: "")
			
			showStationDetails()
            //Perform a segue here to navigate to another viewcontroller
            // On tapping the disclosure button you will get here
        }
    }
	
	// animate annotation views drop
	func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
			for annView in views {

				// animate any annotation views except the user pin
				if !(annView.annotation?.isKind(of: MKUserLocation.self))! {
					let endFrame = annView.frame
					annView.frame = endFrame.offsetBy(dx: 0, dy: -500)
					UIView.animate(withDuration: 0.75, animations: {
						annView.frame = endFrame
					})
				}
			}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		if (annotation is MKUserLocation) {
			 return nil
		}
		// try to dequeue an existing pin view first
		let AnnotationIdentifier = "AnnotationIdentifier"

		let myAnnotation1 = (annotation as! Annotation)
		let id = myAnnotation1.id
		self.stationObj = nil
		
		for oStation in self.listeStations{
			print("searching: " + id!)
			if(oStation.idStation == id){
				print("found: " + oStation.idStation)
				self.stationObj = oStation
			}else{
				print(oStation.idStation)
			}
		}
		
		let smallSquare = CGSize(width: 30, height: 30)
		let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
		button.setBackgroundImage(UIImage(named: "icon_info"), for: .normal)
		
		let pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: AnnotationIdentifier)
		pinView.canShowCallout = true
		pinView.leftCalloutAccessoryView = button
//		button.addTarget(self, action: #selector(stationsSearchViewCrontroller.showAnnotationDisclosure(sender:)), for: .touchUpInside)
		
		self.stationPosition = CLLocationCoordinate2D(latitude: self.stationObj!.latitude, longitude: self.stationObj!.longitude)
		
//		showRouteOnMap(pickupCoordinate: self.myPosition!, destinationCoordinate: self.stationPosition!)
		
		let imgName = myAnnotation1.strImgUrl
		if(UIImage(named: imgName!) != nil){
			pinView.image = self.ResizeImage(image: UIImage(named: imgName!)!, targetSize: CGSize(46.0, 46.0))
		}else{
			pinView.image = self.ResizeImage(image: UIImage(named: "icon_fuels")!, targetSize: CGSize(46.0, 46.0))
		}
		pinView.layer.cornerRadius = 8.0
		pinView.backgroundColor = UIColor.white
		pinView.layer.borderWidth = 0.5
//		pinView.animatesDrop = true
		return pinView
	}
	
	@objc func hideAnnotationDisclosure(sender: MyButton) {
		print("Hide button clicked")
		hideStationDetails()
	}
}

extension stationsSearchViewCrontroller : CLLocationManagerDelegate, FloatingPanelControllerDelegate {
    
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
			self.myLocation = location
			self.myPosition = location.coordinate
			
			let geoCoder = CLGeocoder()
			geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, _) -> Void in
				placemarks?.forEach { (placemark) in
					if let city = placemark.country {
						print(city)
					
						if(city == "France"){
							self.locationManager.stopUpdatingLocation()
							self.listeStations = []
							let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
							let region = MKCoordinateRegion(center: location.coordinate, span: span)
//							let region = self.mapView.region
							self.mapView.setRegion(region, animated: true)
							
							self.listeStationsBDD = try! Realm().objects(stationsBDD.self).filterGeoRadius(center: location.coordinate, radius: 5000, sortAscending: nil)
							
							for station in self.listeStationsBDD{
								let stationItem = Utility.convStationBDDToStationObject(stationBDD: station)
								self.listeStations.append(stationItem)
							}
							self.fetchStationsOnMap()
						}else{
//							self.listeStations = []
							self.performSearchRequest(location: location, completion: {
								(count) in
								print("count = %@",count)
								if(count > 0){
									self.locationManager.stopUpdatingLocation()
									self.fetchStationsOnMap()
								}
							})
						}
					}
				}
			})
		}
	}
	
	/* Cette fonction lance une recherche des stations */
	func performSearchRequest(location:CLLocation, completion: @escaping (Int)-> Void) {
		print("performSearchRequest")
		
		let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
		let region = MKCoordinateRegion(center: location.coordinate, span: span)
//		let region = self.mapView.region
		self.mapView.setRegion(region, animated: true)
		
		self.mklocalSearchRequest = MKLocalSearch.Request()
		
		let naturalLanguageQuery = "Fuel"
		self.mklocalSearchRequest!.naturalLanguageQuery = naturalLanguageQuery
		self.mklocalSearchRequest!.region = region
			
		print("naturalLanguageQuery",naturalLanguageQuery)
		self.mklocalSearch = MKLocalSearch(request: self.mklocalSearchRequest!)
		self.mklocalSearch!.start { (response, error) in
			guard error == nil else { return }
			guard let response = response else {
				print("mklocalsearch, pas de résultat")
				return
			}
			guard response.mapItems.count > 0 else { return }
			//
			print("MKLocalSearch")
			let randomIndex = Int(arc4random_uniform(UInt32(response.mapItems.count)))
			_ = response.mapItems[randomIndex]
			
			for locationItem in response.mapItems {
					
				let loc = CLLocation(latitude: locationItem.placemark.coordinate.latitude, longitude:locationItem.placemark.coordinate.longitude)
					
				let distanceBrute = (self.myLocation!.distance(from: loc))/1000
				let distance = String(format: "%.2f", distanceBrute)
				let nom = locationItem.name
				var adresse = ""
				var codePostal = ""
				var Ville = ""
				
				if(locationItem.placemark.subThoroughfare) != nil{
					adresse = locationItem.placemark.subThoroughfare!
				}
				if(locationItem.placemark.thoroughfare) != nil {
					adresse = adresse + " " + locationItem.placemark.thoroughfare!
				}
				if(locationItem.placemark.postalCode) != nil {
					codePostal = locationItem.placemark.postalCode!
					print("codePostal : %@",codePostal)
				}
				if(locationItem.placemark.locality) != nil {
					Ville =  locationItem.placemark.locality!
					print("Ville : %@",Ville)
				}
				let idStation = self.createId()
				print("idStation = %@",idStation)
				
				let strDistance = distance.description
				print("strDistance ",strDistance)
				let loklak = loc.coordinate.latitude.description + ", " + loc.coordinate.longitude.description
				let dbRef = Database.database().reference()
				let StationRef = Database.database().reference(withPath: "Station")
				dbRef.child("Station").observe(.value, with: { (snapshot) in
					if let result = snapshot.children.allObjects as? [DataSnapshot] {
						for child in result {
							var orderID = child.key as! String
							print(orderID)
						}
					}
				})
				let location = stationObject(idStation: idStation, nom: nom!, marque: nom!, adresse: adresse, codePostal: codePostal, ville: Ville, distance: strDistance + " km", latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, services: "-", prixEssPlus: "0.00", majEssPlus: "", ruptureEssPlus: "Non", prixSP95E10: "0.00", majSP95E10: "", ruptureSP95E10: "Non", prixSP95: "0.00", majSP95: "", ruptureSP95: "Non", prixSP98: "0.00", majSP98: "", ruptureSP98: "Non", prixSUPER: "0.00", majSUPER: "", ruptureSUPER: "Non", prixDieselPlus: "0.00", majDieselPlus: "", ruptureDieselPlus: "Non", prixDiesel: "0.00", majDiesel: "", ruptureDiesel: "Non", prixGPL: "0.00", majGPL: "", ruptureGPL: "Non", prixEthanol: "0.00", majEthanol: "", ruptureEthanol: "Non")
				self.listeStations.append(location)
				self.matchingItems = response.mapItems
				print("listeStations is %@",self.listeStations.count)
				completion(self.listeStations.count)
			}
		}
	}
	
	func showStationDetails(){
		
		// Initialize a `FloatingPanelController` object.
		fpc = FloatingPanelController()
		// Assign self as the delegate of the controller.
		fpc.delegate = self
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let contentVC = storyboard.instantiateViewController(withIdentifier: "StationMapDetail") as! StationDetailMapTableViewController
		contentVC.stationObj = self.stationObj
		contentVC.station = Utility.convStationObectToStation(stationObj: self.stationObj!)
		contentVC.myPosition = self.myPosition
		fpc.set(contentViewController: contentVC)

		// Track a scroll view(or the siblings) in the content view controller.
		fpc.track(scrollView: contentVC.tableView)

		// Add and show the views managed by the `FloatingPanelController` object to self.view.
		//        fpc.addPanel(toParent: self)
		fpc.contentMode = .fitToBounds
		fpc.isRemovalInteractionEnabled = true // Optional: Let it removable by a swipe-down
		fpc.surfaceView.containerMargins = .init(top: 20.0, left: 16.0, bottom: 16.0, right: 16.0)
		fpc.surfaceView.contentInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
		
		self.present(fpc, animated: true, completion: nil)
	}
	
	func hideStationDetails(){
		
		self.removeFromParent()
		
	}
	
	func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
		let size = image.size

		let widthRatio  = targetSize.width  / image.size.width
		let heightRatio = targetSize.height / image.size.height

		// Figure out what our orientation is, and use that to form the rectangle
		var newSize: CGSize
		if(widthRatio > heightRatio) {
			newSize = CGSize(size.width * heightRatio, size.height * heightRatio)
		} else {
			newSize = CGSize(size.width * widthRatio,  size.height * widthRatio)
		}

		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(0, 0, newSize.width, newSize.height)

		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		return newImage
	}
	
	func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
		
		let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
		let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
		
		let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
		let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
		
		let sourceAnnotation = MKPointAnnotation()
		
		if let location = sourcePlacemark.location {
			sourceAnnotation.coordinate = location.coordinate
		}
		
		let destinationAnnotation = MKPointAnnotation()
		
		if let location = destinationPlacemark.location {
			destinationAnnotation.coordinate = location.coordinate
		}
		
		self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
		
		let directionRequest = MKDirections.Request()
		directionRequest.source = sourceMapItem
		directionRequest.destination = destinationMapItem
		directionRequest.transportType = .automobile
		
		// Calculate the direction
		let directions = MKDirections(request: directionRequest)
		
		directions.calculate {
			(response, error) -> Void in
			
			guard let response = response else {
				if let error = error {
					print("Error: \(error)")
				}
				
				return
			}
			
			let route = response.routes[0]
			let eta = route.expectedTravelTime
			let distance = Double(round(route.distance)/1000)
			
//			let temps = self.secondsToHoursMinutesSeconds(seconds: Int(eta))
//
//            self.labelDistanceStation.text = distance.description + " km"
//            self.labelTempsEstime.text = temps
            
			self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
			
			let rect = route.polyline.boundingMapRect
			self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
		}
	}
	
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		let renderer = MKPolylineRenderer(overlay: overlay)
		renderer.strokeColor = UIColor(red: 255.0/255.0, green: 47.0/255.0, blue: 17.0/255.0, alpha: 1)
		renderer.lineWidth = 2.0
		return renderer
	}
	
	func fetchStationsOnMap() {
		
		for station in self.listeStations {
			print(station.nom)
			
			mapView.delegate = self
			mapView.mapType = .standard
			mapView.isZoomEnabled = true
			mapView.isScrollEnabled = true
			mapView.showsUserLocation = true
			
			let myAnnotation1: Annotation = Annotation.init(coordinates: CLLocationCoordinate2D.init(latitude: station.latitude, longitude: station.longitude), title1: station.marque, subtitle1: station.ville, imgURL: station.marque.uppercased(), idStation: station.idStation)
			
			
			
			self.mapView.addAnnotation(myAnnotation1)
			CWProgressHUD.dismiss()
//			let annotations = MKPointAnnotation()
//			annotations.title = station.marque
//			annotations.coordinate = CLLocationCoordinate2D(latitude:station.latitude, longitude: station.longitude)
//			annotations.subtitle = station.ville
//			mapView.addAnnotation(annotations)
	  }
	}
	
	func loadAds(){
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8249099547869316~4988744906")
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        self.langue = UserDefaults.standard.string(forKey: "phoneLanguage")!
        /*bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
         bannerView.rootViewController = self
         bannerView.load(GADRequest())*/
        
        bannerView.delegate = self
        
        //Update consent status
        PACConsentInformation.sharedInstance.requestConsentInfoUpdate(forPublisherIdentifiers: ["pub-8249099547869316"])
        {
            (_ error: Error?) -> Void in
			
            if let error = error {
                print("Consent info update failed.")
            } else {
				
                // Consent info update succeeded. The shared PACConsentInformation
                // instance has been updated.
                print("Consent info update succeeded")
				print("consentStatus = ", PACConsentInformation.sharedInstance.consentStatus.rawValue)
				
				if(UserDefaults.standard.object(forKey: "consentStatus") != nil){
					self.consentState = UserDefaults.standard.integer(forKey: "consentStatus")
				}
				print("consentStutus = @%",self.consentState)
				
                //if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown {
				if self.consentState == 0 {
                    print("Consent status unknown")
                    /* Google-rendered consent form */
                    /* PACConsentForm with all three form options */
                    // TODO: Replace with your app's privacy policy url.
                    // Collect consent
                    
                    var url = ""
                    if(self.langue == "fr"){
                        url = "https://drive.google.com/open?id=1TTrsdtYb2yPHBm2ki4fdm1s1Z65rnz8Q"
                    }else{
                        url = "https://drive.google.com/open?id=1tF8Vb9mi5moFjJapUoQyy9snIcprvZeV"
                    }
                    
                    guard let privacyUrl = URL(string: url),
                        let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                            print("incorrect privacy URL.")
                            return
                    }
                    form.shouldOfferPersonalizedAds = true
                    form.shouldOfferNonPersonalizedAds = true
                    form.shouldOfferAdFree = false
                    
                    form.load {(_ error: Error?) -> Void in
                        print("Load complete.")
                        if let error = error {
                            // Handle error.
                            print("Error loading form: \(error.localizedDescription)")
                        } else {
                            // Load successful.
                            //guard let strongSelf = self else { return }
                            print("Consent form load success")
                            /* Afficher le formulaire de consentement (Show consent form) */
                            form.present(from: self) { (error, userPrefersAdFree) in
                                if let error = error {
                                    // Handle error.
                                } else if userPrefersAdFree {
                                    // User prefers to use a paid version of the app.
									print("user prefers adFree")
                                }else{
                                    print("user don't prefer adFree")
                                    // Check the user's consent choice.
									let status = PACConsentInformation.sharedInstance.consentStatus
									if status == PACConsentStatus.nonPersonalized {
										UserDefaults.standard.set(1, forKey: "consentStatus")
										self.consentState = 1
									}
									if status == PACConsentStatus.personalized {
										UserDefaults.standard.set(2, forKey: "consentStatus")
										self.consentState = 2
									}
									if status == PACConsentStatus.unknown {
										UserDefaults.standard.set(0, forKey: "consentStatus")
										self.consentState = 0
									}
									
									//UserDefaults.standard.set(PACConsentInformation.sharedInstance.consentStatus, forKey: "consentStatus")
									print(status.rawValue)
								}
                            }
                        }
                    }
                }
				
                //if (PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized || PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.personalized){
				if(self.consentState == 1 || self.consentState == 2){
                    print("The user has granted consent for personalized ads.")
                    
                    self.bannerView.isHidden = false
                    self.bannerView.adUnitID = "ca-app-pub-8249099547869316/5778124533"
                    self.bannerView.rootViewController = self
                    let request = GADRequest()
                    
                    //if PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.nonPersonalized {
					if(self.consentState == 1){
                        print("The user has granted consent for non-personalized ads.")
                        // Forward consent to the Google Mobile Ads SDK
                        let extras = GADExtras()
                        extras.additionalParameters = ["npa": "1"]
                        request.register(extras)
                    }else {
                        // Check the user's consent choice.
                        let status = PACConsentInformation.sharedInstance.consentStatus
                    }
                    self.bannerView.load(request)
                }
            }
        }
        let adProviders = PACConsentInformation.sharedInstance.adProviders
        print("adProviders",adProviders)
    }
	
	func createId() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "HHmmss.SSSXXX"
		
		return "Station-" + dateFormatter.string(from: Date())
    }
	
	func showsAds(){
		
	}
    
	override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        
        /*if(self.carObjects.count > 1){
            self.btnAddCar.isEnabled = false
        }*/
        
        if(UserDefaults.standard.bool(forKey: "cguAccept") == false){
            print("viewWillAppear presenting CGU -> cguAccept = false")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationViewController = storyboard.instantiateViewController(withIdentifier: "cgu_screen") as! CGUViewController
            
            self.present(destinationViewController, animated: true, completion: nil)
        }
        
        print("tdbVC : viewWillAppear")
        loadAds()
    }
	
    /* Création d'une bannière de pub dans l'app */
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
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
class Annotation: NSObject, MKAnnotation {

	var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
	var title: String?
	var subtitle: String?
	var strTitle: String?
	var strImgUrl: String?
	var strDescr: String?
	var id: String?

	init(coordinates location: CLLocationCoordinate2D, title1: String, subtitle1: String, imgURL: String, idStation: String) {
		super.init()

		print("init" + idStation)
		coordinate = location
		title = title1
		subtitle = idStation
		strTitle = title1
		strImgUrl = imgURL
		strDescr = description
		id = idStation
	}
}


