//
//  LocalisationTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 15/06/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import Contacts
import RealmSwift
import SCLAlertView
import CWProgressHUD
import MobileCoreServices

class LocalisationTableViewController: UITableViewController, CLLocationManagerDelegate {

	var car:Car?
	var localisationOK:Bool?
	let locationManager = CLLocationManager()
	var locationMode:String?
	var carParkingLatitude:Double?
	var carParkingLongitude:Double?
	var maLatitude:Double?
	var maLongitude:Double?
	var locationState:Bool?
	@IBOutlet weak var monAdresse: UILabel!
	
	@IBOutlet weak var MapView: MKMapView!
	@IBOutlet weak var carPseudo: UILabel!
	@IBOutlet weak var dateHeureLocalisation: UILabel!
	@IBOutlet weak var adresseVehicule: UILabel!
	@IBOutlet weak var CPVilleVehicule: UILabel!
	@IBOutlet weak var distanceVehicule: UILabel!
	@IBOutlet weak var imageViewVehicule: UIImageView!
	@IBOutlet weak var buttonMeLocaliser: UIButton!
    @IBOutlet weak var labelTempsEstime: UILabel!
    @IBOutlet weak var labelDistanceEstimee: UILabel!
    
	
	@IBAction func ButtonMeLocaliser(_ sender: UIButton) {
		self.locationMode = "MaPosition"
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		self.locationManager.requestLocation()
		self.locationState = false
		CWProgressHUD.show()
	}
	@IBAction func ButtonMarquerPosition(_ sender: UIButton) {
		marquerPosition()
	}
	func marquerPosition(){
			self.locationMode = "MarquerPositionVehicule"
			self.locationManager.requestWhenInUseAuthorization()
			self.locationManager.startUpdatingLocation()
			self.locationManager.requestLocation()
	}
	@IBAction func ButtonShareLocation(_ sender: UIButton) {
		marquerPosition()
		let maLatitude = self.maLatitude!.description
		let maLongitude = self.maLongitude!.description
		let maPosition = maLatitude + " " + maLongitude
		let monAdresse = self.monAdresse.text
		//let image = UIImage(self.MapView.
		let url = NSURL(string:"comgooglemaps://?saddr=&daddr=\(maLatitude),\(maLongitude)&directionsmode=driving")
		let shareAll = ["Voici ma position: \n" + monAdresse! + "\n", url] as [Any]
		
		let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
		present(activityViewController, animated: true, completion: nil)
	}
	
	@IBAction func ButtonNaviguerVersVehicule(_ sender: UIButton) {
		let carLatitude = self.car?.parkingLatitude
		let carLongitude = self.car?.parkingLongitude
		
		if(carLatitude != 0){
			let coordinates = CLLocationCoordinate2DMake(self.car!.parkingLatitude, self.car!.parkingLongitude)
			let addressDict = [CNPostalAddressStreetKey: self.adresseVehicule.text, CNPostalAddressCityKey: self.CPVilleVehicule.text, CNPostalAddressStateKey: "France", CNPostalAddressPostalCodeKey: self.CPVilleVehicule.text] as [String : Any]
			let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: addressDict)
			let mapitem = MKMapItem(placemark: placemark)
			let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking]
			mapitem.openInMaps(launchOptions: options)
		}else{
			let appearance = SCLAlertView.SCLAppearance(
				showCloseButton: false
			)
			let popup = SCLAlertView(appearance: appearance)
			
			popup.addButton(textStrings.strOK, backgroundColor: UIColor.gray, textColor: UIColor.white){
			}
			popup.showWarning(textStrings.titlePeuxPasRejoindreVehicule, subTitle: textStrings.messagePeuxPasRejoindreVehicule)
		}
	}
	
	@IBAction func ButtonSaisirAdresse(_ sender: UIButton) {
		inputAddress()
	}
	@IBAction func ButtonEffacerPosition(_ sender: UIButton) {
		let realm = try! Realm()
		try! realm.write {
			self.car?.parkingAdresse = ""
			self.car?.parkingCodePostal = ""
			self.car?.parkingVille = ""
			self.car?.parkingLatitude = 0.00
			self.car?.parkingLongitude = 0.00
			realm.add(self.car!)
		}
		
		self.dateHeureLocalisation.text = "..."
		self.adresseVehicule.text = "Toucher Marquer position"
		self.CPVilleVehicule.text = "pour marquer la position du véhicule"
		self.distanceVehicule.text = "..."
		
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		CWProgressHUD.show()
		/* init */
		self.locationState = false
		self.locationMode = "MaPosition"
 		self.carPseudo.text = self.car?.pseudo
		let idCar = self.car?.idCar
		
		let realm = try! Realm()
		self.car = realm.objects(Car.self).filter("idCar = %@",idCar!).first
		
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.requestLocation()
		
		
		let formatter = DateFormatter()
		formatter.dateFormat = "dd/MM/yyyy HH:mm"
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		let dateHeure = formatter.string(from: self.car?.dateLocalisation as! Date)
		
		if(self.car?.parkingAdresse == ""){
			self.adresseVehicule.text = "Aucune"
			self.CPVilleVehicule.text = "localisation"
			self.dateHeureLocalisation.text = ""
		}else{
			self.adresseVehicule.text = self.car?.parkingAdresse
			self.CPVilleVehicule.text = self.car!.parkingCodePostal + " " + self.car!.parkingVille
			self.dateHeureLocalisation.text = "Localisé le " + (dateHeure)
		}
		
		let carImage = UIImage(data: self.car?.data as! Data)
		self.imageViewVehicule.image = carImage
		
        // Uncomment the following line to preserve selection between prewwasentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
	
	/* Cette fonction vérifie les autorisations pour le GPS, si tout est OK, lance une recherche des stations */
	func checkUsersLocationServicesAuthorization(){
		
		
		switch CLLocationManager.authorizationStatus() {
			
			case .notDetermined:
				// Request when-in-use authorization initially
				// This is the first and the ONLY time you will be able to ask the user for permission
				self.locationManager.delegate = self
				locationManager.requestWhenInUseAuthorization()
				self.localisationOK = false
				break
			
			case .restricted, .denied:
				// Disable location features
				
				let popup = SCLAlertView()
				popup.addButton(textStrings.settingsButton, backgroundColor: UIColor.gray, textColor: UIColor.white){
					guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
						return
					}
					if UIApplication.shared.canOpenURL(settingsUrl) {
						UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
							print("Settings opened: \(success)")
						})
					}
				}
				popup.showError(textStrings.titleEnableGPS, subTitle: textStrings.messageEnableGPS)
				break
			
			case .authorizedWhenInUse, .authorizedAlways:
				// Enable features that require aaaation services here.
				print("Full Access")
				self.localisationOK = true
				print("authorizedWhenInUse-out")
				break
		}
		
	}
	
	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			manager.requestLocation()
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		if(self.locationMode == "MaPosition"){
			if locations.first != nil {
				
				/* Géolocalisation de l'utilisateur */
				print("location:: (location)")
				let location = locations.first
				
				print("locationManager : LocalisationTableViewController")
				let centerOnCurrentLocation = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
				let region = MKCoordinateRegion(center: centerOnCurrentLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
				
				/* Géolocalisation du véhicule si existant */
				let latitudeVehicule = self.car?.parkingLatitude
				let longitudeVehicule = self.car?.parkingLongitude
				let CLLLocVehicule = CLLocation(latitude: latitudeVehicule!, longitude: longitudeVehicule!)
				let CLLocUser = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
				
				/* Calcul de la distance au véhicule */
				let rawDistance = (CLLLocVehicule.distance(from: CLLocUser))///1000
				let distance = String(format: "%.2f", rawDistance)
				print(distance)
				
				self.locationManager.stopUpdatingLocation()
				
				/* Mise à jour de la carte avec les positions */
				for annotation in self.MapView.annotations {
					if let title = annotation.title, title == "Moi" {
						self.MapView.removeAnnotation(annotation)
					}
				}
				let myPIN = MKPointAnnotation()
				myPIN.coordinate = location!.coordinate
				myPIN.title = "Moi"
				
				self.MapView.addAnnotation(myPIN)
				self.MapView.setRegion(region, animated: false)
				
				/* Enregistrement de la position de l'utilisateur pour une réutilisation ultérieure */
				self.maLatitude = location?.coordinate.latitude
				self.maLongitude = location?.coordinate.longitude
				
				/* Mise à jour de l'adresse */
				getAdressFromLocation(loc: CLLocUser, completion: {
					(adresse) in
					print("adresse = " + adresse.count.description)
					if(adresse.count == 4){
						
						let adresseComplete = (adresse[0] as String) + ", " + (adresse[1] as String) + ", " + (adresse[2] as String) + " " + (adresse[3] as String)
						print("Adresse actuelle" + adresseComplete)
						
						/* Affichage adresse et distance */
						self.monAdresse.text = adresseComplete
						self.distanceVehicule.text = "Vous etes à " + distance + "m de votre véhicule."
						
						self.locationState = true
						CWProgressHUD.showSuccess(withMessage: "Vous êtes localisé")
						CWProgressHUD.dismiss()
					}
				})
				
                
			}
		}
		if(self.locationMode == "MarquerPositionVehicule"){
			if locations.first != nil {
				print("location:: (location)")
				
				/* Obtention de la position de l'utilisateur pour marquage véhicule */
				let location = locations.first
				self.locationMode == "MaPosition"
				print("locationManager : LocalisationTableViewController")
				let centerOnCurrentLocation = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
				let region = MKCoordinateRegion(center: centerOnCurrentLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
				
				self.locationManager.stopUpdatingLocation()
				
				/* Mise à jour de la position du véhicule sur la carte */
				let myCar = MKPointAnnotation()
				myCar.coordinate = location!.coordinate
				myCar.title = self.car?.pseudo
				
				self.MapView.addAnnotation(myCar)
				self.MapView.setRegion(region, animated: true)
				
				/* Enregistrement de la position véhicule dans la base */
				let locVeh = CLLocation(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
				getAdressFromLocation(loc: locVeh, completion: {
					(adresse) in
					print("adresse = " + adresse.count.description)
					if(adresse.count == 4){
						let adresseString = (adresse[0] as String) + ", " + (adresse[1] as String)
						let codepostal = adresse[2]
						let ville = adresse[3]
						
						let realm = try! Realm()
						try! realm.write {
							self.car?.parkingAdresse = adresseString
							self.car?.parkingCodePostal = codepostal as String
							self.car?.parkingVille = ville as String
							self.car?.parkingLatitude = location!.coordinate.latitude
							self.car?.parkingLongitude = location!.coordinate.longitude
							
							realm.add(self.car!)
						}
						
						/* Affichage des infos sur l'écran */
						self.adresseVehicule.text! = self.car!.parkingAdresse
						self.CPVilleVehicule.text! = self.car!.parkingCodePostal + " " + self.car!.parkingVille
					}
				})
				
			}
		}
        let carLocation = CLLocationCoordinate2D(latitude: self.car!.parkingLatitude,longitude: self.car!.parkingLongitude)
        let myLocation = CLLocationCoordinate2D(latitude: self.maLatitude!, longitude: self.maLongitude!)
		showRouteOnMap(pickupCoordinate: carLocation, destinationCoordinate: myLocation)
	}
	func convAddress2Coord(address:String, completion: @escaping (_ addressFound: Bool) -> Void){
		//let address = "1 Infinite Loop, Cupertino, CA 95014"
		
		let geoCoder = CLGeocoder()
		geoCoder.geocodeAddressString(address) { (placemarks, error) in
			guard
				let placemarks = placemarks,
				let location = placemarks.first?.location
				else {
					// handle no location found
					
					let appearance = SCLAlertView.SCLAppearance(
						showCloseButton: false
					)
					let popup = SCLAlertView(appearance: appearance)
					
					popup.addButton(textStrings.strOK, backgroundColor: UIColor.gray, textColor: UIColor.white){
					}
					popup.showWarning(textStrings.titleAdresseInexistante, subTitle: textStrings.messageAdresseInexistante)
					
					completion(false)
					return
				}
			self.carParkingLatitude = location.coordinate.latitude
			self.carParkingLongitude = location.coordinate.longitude
			// Use your location
			completion(true)
		}
	}
	
	func getAdressFromLocation(loc:CLLocation, completion: @escaping (_ adresse: [NSString])-> Void){
		//var address: String = ""
		let street = ""
		let zip = ""
		let city = ""
		var complete:Bool?
		
		let geoCoder = CLGeocoder()
		geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) -> Void in
			var addressArray = [NSString]()
			// Place details^ùm
			var placeMark: CLPlacemark!
			placeMark = placemarks?[0]
			
			// Address dictionary
			//print(placeMark.addressDictionary ?? "")
			
			// Location name
			/*if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
				print(locationName)
			}*/
			// Street number
			if(placeMark != nil){
				if let number = placeMark.addressDictionary!["SubThoroughfare"] as? NSString {
					print(number)
					addressArray.append(number as NSString)
					//self.adresseVehicule.text = street as String
				}
			
				// Street address
				if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
					print(street)
					addressArray.append(street as NSString)
					//self.adresseVehicule.text = street as String
				}
			
				// Zip code
				if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
					print(zip)
					addressArray.append(zip as NSString)
					//address = address + ", " + (zip as String)
					//self.CPVilleVehicule.text = (zip as String)
				}
			
				// City
				if let city = placeMark.addressDictionary!["City"] as? NSString {
					print(city)
					addressArray.append(city)
					//address = address + " " + (city as String)
					//self.CPVilleVehicule.text = self.CPVilleVehicule.text! + " " + (city as String)
				}
			}
			completion(addressArray)
		})
	}

	
	//func locationManager(_ manager: CLLocationManager, didFailWithError error: NSError) {
		
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Swift.Error) {
		print("error:: (error)")
	}
	
	func inputAddress() {
		//Step : 1
		let alert = UIAlertController(title: "Localisation véhicule", message: "Saisir l'adresse du véhicule", preferredStyle: UIAlertController.Style.alert)
		//Step : 2
		let save = UIAlertAction(title: "Enregistrer", style: .default) { (alertAction) in
			let textFieldAddress = alert.textFields![0] as UITextField
			let textFieldCity = alert.textFields![1] as UITextField
			
			self.adresseVehicule.text = textFieldAddress.text
			self.CPVilleVehicule.text = textFieldCity.text
			
			
			let adresse = self.adresseVehicule.text! + ", " + self.CPVilleVehicule.text!

			self.convAddress2Coord(address: adresse, completion: {
				(addressFound) in
			
				if(addressFound){
					let realm = try! Realm()
					try! realm.write {
						self.car?.parkingAdresse = textFieldAddress.text!
						self.car?.parkingVille = textFieldCity.text!
						
						/* A décommenter après traitement par completion */
						self.car?.parkingLatitude = self.carParkingLatitude!
						self.car?.parkingLongitude = self.carParkingLongitude!
						
						realm.add(self.car!)
					}
					
					let myCar = MKPointAnnotation()
					let coord = CLLocationCoordinate2D(latitude: self.carParkingLatitude!, longitude: self.carParkingLongitude!)
					myCar.coordinate = coord
					myCar.title = self.car?.pseudo
					
					let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
					
					self.MapView.addAnnotation(myCar)
					self.MapView.setRegion(region, animated: true)
				}
			})
		}
		
		//Step : 3
		//For first TF
		alert.addTextField { (textField) in
			textField.placeholder = "Saisir une adresse"
			textField.text = self.car?.parkingAdresse
			textField.textColor = .red
		}
		//For second TF
		alert.addTextField { (textField) in
			textField.placeholder = "Saisir une ville"
			textField.text = self.car?.parkingVille
			textField.textColor = .blue
		}
		
		//Step : 4
		alert.addAction(save)
		//Cancel action
		let cancel = UIAlertAction(title: "Cancel", style: .default) { (alertAction) in }
		alert.addAction(cancel)
		//OR single line action
		//alert.addAction(UIAlertAction(title: "Cancel", style: .default) { (alertAction) in })
		
		self.present(alert, animated:true, completion: nil)
		
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
		
		self.MapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
		
		let directionRequest = MKDirections.Request()
		directionRequest.source = sourceMapItem
		directionRequest.destination = destinationMapItem
		directionRequest.transportType = .walking
		
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
			
			let temps = self.secondsToHoursMinutesSeconds(seconds: Int(eta))
			
			self.labelDistanceEstimee.text = distance.description + " km"
			self.labelTempsEstime.text = temps
			
			self.MapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
			
			let rect = route.polyline.boundingMapRect
			self.MapView.setRegion(MKCoordinateRegion(rect), animated: true)
		}
	}
	
	func secondsToHoursMinutesSeconds (seconds : Int) -> (String) {
		var tps:String = "Calcul..."
		if(seconds>3600){
			let h = seconds/3600
			let m = (seconds % 3600)/60
			let s = (seconds % 3600) % 60
			return h.description + "h " + m.description + " min."
		}
		if(seconds<3600){
			let m = (seconds % 3600)/60
			let s = (seconds % 3600) % 60
			return m.description + " min."
		}
		return tps
	}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 255.0/255.0, green: 47.0/255.0, blue: 17.0/255.0, alpha: 1)
        renderer.lineWidth = 2.0
        return renderer
    }
	/*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last
		print("locationManager : LocalisationTableViewController")
		let centerOnCurrentLocation = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
		let region = MKCoordinateRegion(center: centerOnCurrentLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
		
		/*let stationCoordinates = CLLocationCoordinate2DMake(Double(self.station!.latitude), Double(self.station!.longitude))
		let addressDictStation = [CNPostalAddressStreetKey: self.station?.nom, CNPostalAddressCityKey: self.station?.ville, CNPostalAddressStateKey: "France", CNPostalAddressPostalCodeKey: self.station?.codePostal]
		let placemarkStation = MKPlacemark(coordinate: stationCoordinates, addressDictionary: addressDictStation)
		
		let myCoordinates = CLLocationCoordinate2DMake(location!.coordinate.latitude, location!.coordinate.longitude)
		let myAddressDict = [CNPostalAddressStreetKey: "Vous etes ici"]
		let myPlacemark = MKPlacemark(coordinate: myCoordinates, addressDictionary: myAddressDict)*/
		
		
		//bigMap.setRegion(region, animated: true)
		self.locationManager.stopUpdatingLocation()
		
		let myPIN = MKPointAnnotation()
		myPIN.coordinate = location!.coordinate
		myPIN.title = "Vous etes ici"
		
		/*let stationPIN = MKPointAnnotation()
		stationPIN.coordinate = stationCoordinates
		stationPIN.title = self.station?.nom
		let centerregion = MKCoordinateRegion(center: stationCoordinates, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))*/
		
		self.MapView.addAnnotation(myPIN)
		//self.MapView.addAnnotation(stationPIN)
		self.MapView.setRegion(region, animated: true)
		//self.MapView.fitAllMarkers(shouldIncludeCurrentLocation: true)
		//self.MapView.showAnnotations(self.MapView.annotations, animated: true)
	}*/

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
