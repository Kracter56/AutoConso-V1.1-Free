//
//  stationsTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 20/03/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import RealmSwift
import MapKit
import RSLoadingView
import CWProgressHUD
import Firebase
import SCLAlertView
import SwiftyJSON
import GeoQueries

class stationsTableViewController: UITableViewController, CLLocationManagerDelegate {
	
	/* Variables reçues de AddConsoVC */
	var senderVC:String?
	var addConsoVC:AddConsoViewController?
	var stationName:String?			// FuelStation Name
	var searchString:String?		// NaturalQuery search string
	var searchedStation:String?		// Searched Fuel Station
	var searchedAddress:String?		// Searched address
	var searchedVille:String?		// Searched City
	var searchedCP:String?			// Zip code
	var currentGPS:CLLocationCoordinate2D?	// GPS coordinates of the station
	var carName:String?				// Car Name
	var coordGPS:CLLocation?		// Current location GPS coordinates
	var longitudeDistance:Double?	// Prefs de distance en latitude
	var latitudeDistance:Double?	// Prefs de distance en longitude
	var currentAddress:String?
	var car:Car?
	var codePostal:String?
	var bLocalized:Bool?
	var modeRecherche:Int?					// Mode de recherche de stations 0-favoris, 1-recherche, 2-recherche dans ville
	
	var stationSearch:String?
	var CP:String?
	var ville:String?
	
	var station:Station?
	var listeOfStations = [Station]()
	var oConso:Conso?
	var realm:Realm?

	var localisationOK:Bool?
	var stationSearchState:Bool?
	let locationManager = CLLocationManager()
	var currentCoordGPS:CLLocation?
	var coord:CLLocationCoordinate2D?
	var currentLatitude:Double?
	var currentLongitude:Double?
	var searchMode:String?

	/* Local Search & GPS variables */
	var mkLocalSearchRequest:MKLocalSearch.Request?
	var mkLocalSearch:MKLocalSearch?
	var matchingItems:[MKMapItem] = []
	var listeStations = [stationObject]()
	
	@IBOutlet weak var labelNbStations: UILabel!
	/* Firebase */
	var ref: DatabaseReference!
	
	/*  */
	
	
	var loadingView:RSLoadingView?
	
	@IBOutlet weak var tableViewStations: UITableView!
	@IBOutlet var searchStation: UIBarButtonItem!
	
	@IBOutlet weak var segmentedControlTypeRecherche: UISegmentedControl!
	@IBAction func searchStation(_ sender: UIBarButtonItem) {
		
		//*****
		
		// Example of using the view to add two text fields to the alert
		// Create the subview
		let appearance = SCLAlertView.SCLAppearance(
			kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
			kTextFont: UIFont(name: "HelveticaNeue", size: 13)!,
			kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
			showCloseButton: false
		)
		
		// Initialize SCLAlertView using custom Appearance
		let alert = SCLAlertView(appearance: appearance)
		
		// Create the subview
		let subview = UIView(frame: CGRect(0,0,300,160))
		let x = (subview.frame.width - 360) / 2
		
		// Add textfield 1
		/*let textfield1 = UITextField(frame: CGRect(x,10,180,30))
		textfield1.layer.borderColor = UIColor.red.cgColor
		textfield1.layer.borderWidth = 1
		textfield1.layer.cornerRadius = 8
		textfield1.placeholder = "Nom"
		textfield1.textAlignment = NSTextAlignment.center
		subview.addSubview(textfield1)*/
		
		
		// Add textfield 2
		let textfield2 = UITextField(frame: CGRect(x,10,180,30))
		textfield2.layer.borderColor = UIColor.red.cgColor
		textfield2.layer.borderWidth = 1
		textfield2.layer.cornerRadius = 8
		textfield2.keyboardType = .numberPad
		textfield2.layer.borderColor = UIColor.red.cgColor
		textfield2.placeholder = "Code Postal"
		textfield2.textAlignment = NSTextAlignment.center
		subview.addSubview(textfield2)
		
		// Add textfield 3
		let textfield3 = UITextField(frame: CGRect(x,textfield2.frame.maxY + 10,180,30))
		textfield3.layer.borderColor = UIColor.red.cgColor
		textfield3.layer.borderWidth = 1
		textfield3.layer.cornerRadius = 8
		textfield2.layer.borderColor = UIColor.red.cgColor
		textfield3.placeholder = "Ville"
		textfield3.textAlignment = NSTextAlignment.center
		subview.addSubview(textfield3)
		
		
		// Add the subview to the alert's UI property
		alert.customSubview = subview
		alert.addButton("Lancer la recherche", backgroundColor: UIColor.green, textColor: UIColor.black) {
			//if(textfield1.text == ""){textfield1.text = nil}
			if(textfield2.text == ""){textfield2.text = nil}
			if(textfield3.text == ""){textfield3.text = nil}
			
			self.searchedVille = textfield3.text
			self.searchedCP = textfield2.text
			//self.searchedStation = textfield1.text
			
			CWProgressHUD.show(withMessage: textStrings.strRechercheEnCours)
			if((self.searchedVille == "")||(self.searchedVille == nil)){
				
				/*self.searchVilleByCP(codepostal: self.searchedCP!){
					(_ ville: String) in
					print(ville)
				}*/
				/*if((ville != "")&&(ville != nil)){
					print(ville)
				}*/
				
				//let ville = self.searchVilleByCP(codepostal: self.searchedCP!)
			}
			
			if((self.searchedCP == "")||(self.searchedCP == nil)){
				self.searchCPByVille(ville: self.searchedVille!, completion: {
					result in
					if(result.isNumber()){
						print(result)
						self.codePostal = result
						self.searchedCP = self.codePostal
						self.listeStations.removeAll()
						self.displaySearchedStations(station: "", CP: self.searchedCP!, ville: self.searchedVille!, completion: {
							(result) in
							if(result == 1){
								self.tableViewStations.rowHeight = constants.minRowHeight
								self.tableViewStations.reloadData()
								CWProgressHUD.dismiss()
								return
							}
						})
					}else{
						CWProgressHUD.dismiss()
						let alert = SCLAlertView()
						alert.showWarning(textStrings.strErreur, subTitle: textStrings.titleAdresseInexistante)
					}
				})
				
				//self.searchCPByVille(ville: self.searchedVille!)
			}else{
				let message = textStrings.strRechercheEnCours
				CWProgressHUD.show(withMessage: message)
				self.listeStations.removeAll()
				self.displaySearchedStations(station: "", CP: self.searchedCP!, ville: self.searchedVille!, completion: {
					(result) in
					if(result == 1){
						self.tableViewStations.rowHeight = constants.minRowHeight
						self.tableViewStations.reloadData()
						CWProgressHUD.dismiss()
						return
					}
				})
			}
		}
		
		// Add Button with Duration Status and custom Colors
		alert.addButton(textStrings.strFermer, backgroundColor: UIColor.red, textColor: UIColor.white) {
			print("Fermer")
		}
		
		alert.showEdit(textStrings.strChercherStation, subTitle: textStrings.strCritereRecherche)
		
		//*****
	}
	/*@objc func textFieldDidChange(_ textField: UITextField) {
		
		/*searchVilleByCP(codepostal: textField.text!){
			(_ ville: String) in
			print(ville)
		}
		if((ville != "")&&(ville != nil)){
			print(ville)
		}*/
		
		let ville = searchVilleByCP(codepostal: textField.text!)
	}*/
	@IBAction func btnAddStation(_ sender: UIBarButtonItem) {
		
		let AddController = AddStationEurekaViewController()
		self.navigationController?.pushViewController(AddController, animated: true)
		
	}
	
	@IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
		
		// If GPS is disabled, disable the search around me
		/*if(Utility.GPSconnectionState == false){
			segmentedControlTypeRecherche.setEnabled(false, forSegmentAt: 2)
		}else{
			segmentedControlTypeRecherche.setEnabled(true, forSegmentAt: 2)
		}*/
		
		switch segmentedControlTypeRecherche.selectedSegmentIndex
		{
		case 0:
			self.navigationItem.rightBarButtonItem = nil
			self.listeStations.removeAll()
			displayMyStations()
			self.modeRecherche = 0
		case 1:
			self.navigationItem.rightBarButtonItem = self.searchStation
			self.listeStations.removeAll()
			// Button action
			self.searchStation.target?.perform(self.searchStation.action,with: nil)
			self.modeRecherche = 1
		case 2:
			self.navigationItem.rightBarButtonItem = nil
			self.listeStations.removeAll()
			self.modeRecherche = 2
			// If Internet connection is not OK, search for stations on my city
			if(Utility.connectionState == true){
				displayStationsAroundMe()
			}else{
				displayStationsOnMyCity()
			}
			
		default:
			break
		}
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		CWProgressHUD.show(withMessage: textStrings.strChargement)
		self.stationSearchState = false
		
		/* Verification des permissions GPS */
		checkUsersLocationServicesAuthorization()
		
		// Check GPS connection and disable search around me if it is deactivated
		/*if(Utility.GPSconnectionState == false){
			self.segmentedControlTypeRecherche.setEnabled(false, forSegmentAt: 2)
		}else{
			self.segmentedControlTypeRecherche.setEnabled(true, forSegmentAt: 2)
		}*/
		
		self.searchMode = "stationsAroundMe"
		
		
		
		/* Liste des stations de la ville, à l'affichage */
		if(self.senderVC == "AddConsoVC"){
			displayStationsAroundMe()
		}else{
			displayStationsOnMyCity()
		}
		
		
		
	}
	
	func searchVilleByCP(codepostal: String, completion: @escaping (_ ville: String) -> Void) {
		
		let ville = ""
		
		if(codepostal != ""){
			let stationsRef = Database.database().reference().child("Stations").child("Fr").child(codepostal)
			stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
				print(snapshot)
				
				if(snapshot.value is NSNull){
					// NO DATA
					print("– – – Data was not found – – –")
					//CWProgressHUD.dismiss()
				}else{
					for stationItem in snapshot.children {
						// DATA FOUND
						
						let station_snap = stationItem as! DataSnapshot
						let id = station_snap.key as! String
						let dict = station_snap.value as! NSDictionary
		
						let ville = dict["ville"] as! String
						
					}
				}
			})
		}
		completion(ville)
	}

	/* This function searches code postal from city using government API */
	func searchCPByVille(ville: String, completion: @escaping (String)->Void ){
		
		if(Utility.connectionState == true){
			let urlString = "https://geo.api.gouv.fr/communes?nom=" + ville
			
			let request = NSMutableURLRequest(url: URL(string: urlString)!)
			request.httpMethod = "GET"
			
			let requestAPI = URLSession.shared.dataTask(with: request as URLRequest) {data, response, error in
				if (error != nil) {
					print(error!.localizedDescription) // On indique dans la console ou est le problème dans la requête
				}
				if let httpStatus = response as? HTTPURLResponse , httpStatus.statusCode != 200 {
					print("statusCode devrait être de 200, mais il est de \(httpStatus.statusCode)")
					print("réponse = \(response)") // On affiche dans la console si le serveur ne nous renvoit pas un code de 200 qui est le code normal
				}
				
				let responseAPI = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
				print("responseString = \(responseAPI)") // Affiche dans la console la réponse de l'API
				
				if error == nil {
					// Ce que vous voulez faire.
					let response = responseAPI!.description
					var APIdata: NSData = response.data(using: String.Encoding.utf8)! as NSData
					
					do{
						//here dataResponse received from a network request
						let jsonResponse = try JSONSerialization.jsonObject(with:
							data!, options: [])
						
						guard let jsonArray = jsonResponse as? [[String: Any]] else {
							return
						}
						print(jsonArray)
						
						if jsonArray.count > 0 {
							let json = jsonArray[0] as NSDictionary
							//let CP = json["codesPostaux"] as? [String]
							let CP = json.value(forKey: "codesPostaux") as! NSArray
							let sCP = CP[0] as! String
							completion(sCP) // delectus aut autem
						}else{
							completion("Error")
						}
					} catch let parsingError {
						print("Error", parsingError)
					}
				}
			}
			requestAPI.resume()
		}else{
			let realm = try! Realm()
			let stations = realm.objects(stationsBDD.self).filter("ville = %@",ville).first
			let sCP = stations?.codePostal
			print("offline : code postal = %@",sCP?.description)
			completion(sCP!.description)
		}
	}
	
	/* Build the address */
	func buildAdressString(){
		print("buildAddress-in")
		print("searchString-in",self.searchString)
		let addressArray = self.currentAddress?.split(separator: ",")
		
		if(self.stationName == "")||(self.stationName == nil){
			/* Alert string building */
			
			let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
			let popup = SCLAlertView(appearance: appearance)
			popup.addButton(textStrings.strOK, backgroundColor: UIColor.gray, textColor: UIColor.white){
				// Do something when button OK is pressed
			}
			popup.showWarning(textStrings.titleNoStationSelected, subTitle: textStrings.messageNoStationSelected)

			self.stationName = "Station"
			self.searchString = "Station"
			
		}else{
			self.searchString = self.stationName!
		}
		
		if((self.searchedAddress != nil)&&(self.searchedAddress != "")){
			self.searchString = self.searchString! + ", " + self.searchedAddress!
		}
		
		if((self.searchedCP != nil)&&(self.searchedCP != "")){
			//self.searchedCP = addressArray![2].description
			self.searchString = self.searchString! + ", " + self.searchedCP!
		}
		
		if((self.searchedVille != nil)&&(self.searchedVille != "")){
			self.searchString = self.searchString! + ", " + self.searchedVille!
		}
		
		var nomPays = ""
		let locale = Locale.current.identifier
		if(locale.contains("FR")){
			nomPays = "France"
		}
		self.searchString = self.searchString! + ", " + nomPays
		print("buildAddress : searchString",self.searchString)
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
				Utility.GPSconnectionState = false
				let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
				let popup = SCLAlertView(appearance: appearance)
				popup.addButton(textStrings.strOK, backgroundColor: UIColor.green, textColor: UIColor.white){
					// Do something when button OK is pressed
					guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
						return
					}
					if UIApplication.shared.canOpenURL(settingsUrl) {
						UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
							print("Settings opened: \(success)")
						})
					}
				}
				popup.showWarning(textStrings.titleEnableGPS, subTitle: textStrings.messageEnableGPS)
				
				/*SweetAlert().showAlert(textStrings.titleEnableGPS, subTitle: textStrings.messageEnableGPS, style: AlertStyle.customImage(imageFile: "icon_location"), buttonTitle:textStrings.settingsButton, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
				{ action in
					guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
						return
					}
					if UIApplication.shared.canOpenURL(settingsUrl) {
						UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
							print("Settings opened: \(success)")
						})
					}
					
				}*/
				
				break
			
			case .authorizedWhenInUse, .authorizedAlways:
				// Enable features that require aaaation services here.
				print("Full Access")
				Utility.GPSconnectionState = true
				self.localisationOK = true
				print("authorizedWhenInUse-out")
				break
		}
	}
	
	/* Cette fonction renvoie les coordonnées GPS d'une adresse donnée */
	func getCoordinatesFromAddress(Address:String){
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(Address) {
			placemarks, error in
			if((error) != nil){
				print("Error", error)
			}
			if let placemarks = placemarks {
				if placemarks.count != 0 {
					let coordinates = placemarks.first!.location
					print("getCoordinatesFromAddress",coordinates?.description)
					self.coordGPS = coordinates
				}
			}
		}
	}
	
	/* Performs local search using searchString */
	func performLocalSearch(completionHandler: @escaping (Bool) -> Void) {
		print("performLocalSearch-in")
		self.listeStations.removeAll()
		// The map is centered using current GPS coordinates
		let center = self.currentGPS
		
		// The region's center is the same point than center but
		//let region = MKCoordinateRegion(center: self.currentGPS)!,
		let region = MKCoordinateRegion(center: (self.coordGPS?.coordinate)!, latitudinalMeters: self.latitudeDistance!, longitudinalMeters: self.longitudeDistance!)
		
		let naturalLanguageQuery = "Station service"
		print("naturalLanguageQuery = %@",naturalLanguageQuery)
		self.mkLocalSearchRequest = MKLocalSearch.Request()
		self.mkLocalSearchRequest?.naturalLanguageQuery = naturalLanguageQuery
		self.mkLocalSearchRequest?.region = region
		self.mkLocalSearch = MKLocalSearch(request: self.mkLocalSearchRequest!)
		
		DispatchQueue.main.async { [weak self] in
			
			self!.mkLocalSearch!.start { (response, error) in
				guard error == nil else {
					print("mklocalSearch : error = nil")
					return }
				guard let response = response else {
					print("mklocalsearch, pas de résultat")
					return
				}
				
				print("mkLocalSearch is started")
				print("mapItems = " + response.mapItems.count.description)
				guard response.mapItems.count > 0 else {
					return
				}
				
				let groupStationSearch = DispatchGroup()
				
				for locationItem in response.mapItems {
					
					let location = CLLocation(latitude: locationItem.placemark.coordinate.latitude, longitude: locationItem.placemark.coordinate.longitude)
					
					/* Distance from the center calculation */
					let rawDistance = (self!.coordGPS?.distance(from: location))!/1000
					let distance = String(format: "%.2f", rawDistance)
					
					let marque = locationItem.name
					var number = ""
					var address = ""
					var zipcode = ""
					var city = ""
					
					if(locationItem.placemark.subThoroughfare) != nil{
						number = locationItem.placemark.subThoroughfare!
					}
					if(locationItem.placemark.thoroughfare) != nil {
						address = address + " " + locationItem.placemark.thoroughfare!
					}
					if(locationItem.placemark.postalCode) != nil {
						zipcode = locationItem.placemark.postalCode!
						print("codePostal : %@",zipcode)
					}
					if(locationItem.placemark.locality) != nil {
						city =  locationItem.placemark.locality!
						print("Ville : %@",city)
					}
					
					let strDistance = distance.description
					print("itemDistance ",strDistance)
					
					let locationItemCoordinates = locationItem.placemark.coordinate.latitude.description + "," + locationItem.placemark.coordinate.longitude.description
					
					let locationName = marque! + " - " + city
					
					let stationObj = stationObject(idStation: "", nom: locationName, marque: marque!, adresse: number + "," + address, codePostal: zipcode, ville: city, distance: distance + " km", latitude: locationItem.placemark.coordinate.latitude, longitude: locationItem.placemark.coordinate.longitude, services: " ", prixEssPlus: " ", majEssPlus: "", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: "", ruptureSP95E10: "Non", prixSP95: " ", majSP95: "", ruptureSP95: "Non", prixSP98: " ", majSP98: "", ruptureSP98: "Non", prixSUPER: " ", majSUPER: "", ruptureSUPER: "Npn", prixDieselPlus: " ", majDieselPlus: "", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: "", ruptureDiesel: "Non", prixGPL: " ", majGPL: "", ruptureGPL: "Non", prixEthanol: " ", majEthanol: "", ruptureEthanol: "Non")
					
					self!.listeStations.append(stationObj)
					self!.matchingItems = response.mapItems
					
					//completionHandler(true)
					groupStationSearch.enter()
					self!.searchForStation(stationObj, completionHandler: {
						(idStation) in
						//.. Code process
						if(idStation.hasPrefix("Station-")){
							//createNewStation(objStation)
							groupStationSearch.leave()
						}
						if(idStation.hasPrefix("new")){
							//createNewStation(objStation)
							print("Station not exists")
							groupStationSearch.leave()
						}
						
					})
					
				}
				
				
			}
			self!.tableViewStations.rowHeight = constants.minRowHeight
			self!.tableViewStations.reloadData()
			CWProgressHUD.dismiss()
		}
	}
	
	func searchForStation(_ stationObj: stationObject,
						  completionHandler: @escaping (String) -> Void){
		
		var station:stationObject
		var idStation = ""
		
		let zipcode = stationObj.codePostal
		// create searchRef or queryRef you name it
		let stationsRef = Database.database().reference().child("Stations").child("Fr").child(zipcode!)
		stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
			print(snapshot)
			
			/*print("Recherche de : " + marque!)
			print("adresse : " + address)
			print("ville: " + city + " non trouvé")*/
			
			if(snapshot.value is NSNull){
				// NO DATA
				print("– – – Data was not found – – –")
				//CWProgressHUD.dismiss()
			}else{
				for stationItem in snapshot.children {
					// DATA FOUND
					
					let station_snap = stationItem as! DataSnapshot
					let id = station_snap.key as! String
					let dict = station_snap.value as! NSDictionary
					
					// Get the coordinates of each element of list and calculate distance
					let stationItemLatitude = (dict["latitude"] as! NSString).replacingOccurrences(of: ",", with: ".")
					let stationItemLongitude = (dict["longitude"] as! NSString).replacingOccurrences(of: ",", with: ".")
					
					let stationLocation = CLLocation(latitude: (stationItemLatitude as NSString).doubleValue, longitude: (stationItemLongitude as NSString).doubleValue)
					
					/* Distance from the center calculation */
					let rawDistance = stationLocation.distance(from: stationLocation)/1000
					let distance = String(format: "%.2f", rawDistance)
					
					idStation = dict["idStation"] as! String
					let marque = dict["marque"] as! String
					let nomStation = dict["nomStation"] as! String
					let adresse = dict["adresse"] as! String
					let codepostal = dict["codePostal"] as! String
					let ville = dict["ville"] as! String
					let pays = dict["pays"] as! String
					let commentaire = dict["commentaire"] as! String
					
					/*self!.listeStations.insert(stationObject(idStation: id, nom: nomStation, marque: marque, adresse: adresse, codePostal: codepostal.description, ville: ville, distance: "", latitude: Float(stationItemLatitude), longitude: Float(stationItemLongitude)), at: 0)
					self!.tableViewStations.reloadData()*/
				}
			}
		})
		completionHandler(idStation)
	}
	
	func displaySearchedStations(station:String, CP:String, ville:String, completion: @escaping (Int)->Void){
		if(Utility.connectionState == true){
			// create searchRef or queryRef you name it
			let stationsRef = Database.database().reference().child("Stations").child("Fr").child(CP.description)
			stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
				print(snapshot)
				
				if(snapshot.value is NSNull){
					// NO DATA
					print("– – – Data was not found – – –")
					self.listeStations.removeAll()
					let appearance = SCLAlertView.SCLAppearance(
						showCloseButton: false
					)
					let alertVw = SCLAlertView(appearance: appearance)
					alertVw.addButton(textStrings.strOui, backgroundColor: UIColor.green, textColor: UIColor.white) {
						print("Yes Button tapped")
						let AddController = AddStationEurekaViewController()
						self.navigationController?.pushViewController(AddController, animated: true)
					}

					alertVw.addButton(textStrings.strNon, backgroundColor: UIColor.red, textColor: UIColor.white) {
						print("No Button tapped")
					}
					alertVw.showError(textStrings.titleAucuneStation, subTitle: textStrings.messageAucuneStation)
					self.labelNbStations.text = "Aucune station trouvée."
					CWProgressHUD.dismiss()
				}else{
					self.listeStations.removeAll()	// Clean the listeStations array before filling it
					for stationItem in snapshot.children {
						// DATA FOUND
						let station_snap = stationItem as! DataSnapshot
						let id = station_snap.key as! String
						let dict = station_snap.value as! NSDictionary
						
						let marque = dict["marque"] as! String
						let nomStation = dict["nomStation"] as! String
						let adresse = dict["adresse"] as! String
						let codepostal = dict["codePostal"] as! String
						let ville = dict["ville"] as! String
						let pays = dict["pays"] as! String
						let commentaire = dict["commentaire"] as! String
						let sLatitude = dict["latitude"] as! String
						let sLongitude = dict["longitude"] as! String
						let services = dict["services"] as! String
						
						let prixDieselPlus = dict["DieselPlus_prix"] as! String
						let prixDieselPlusMaj = dict["DieselPlus_maj"] as! String
						let prixEssencePlus = dict["EssencePlus_prix"] as! String
						let prixEssencePlusMaj = dict["EssencePlus_maj"] as! String
						let prixGazole = dict["Gazole_prix"] as! String
						let prixGazoleMaj = dict["Gazole_maj"] as! String
						let prixSP95E10 = dict["E10_prix"] as! String
						let prixSP95E10Maj = dict["E10_maj"] as! String
						let prixSP95 = dict["SP95_prix"] as! String
						let prixSP95Maj = dict["SP95_maj"] as! String
						let prixSP98 = dict["SP98_prix"] as! String
						let prixSP98Maj = dict["SP98_maj"] as! String
						let prixSUP = dict["SP98_prix"] as! String		// Remplacer SUPER qui n'existe plus par GPL
						let prixSUPMaj = dict["SP98_maj"] as! String
						let prixEthanol = dict["SP98_prix"] as! String
						let prixEthanolMaj = dict["SP98_maj"] as! String
						let prixGPL = dict["SP98_prix"] as! String
						let prixGPLMaj = dict["SP98_maj"] as! String
						
						// A décommenter une fois que la base firebase sera mise à jour
						/*let prixEthanol = dict["E85_prix"] as! String
						let prixEthanolMaj = dict["E85_maj"] as! String
						let prixGPL = dict["GPL_prix"] as! String
						let prixGPLMaj = dict["GPL_maj"] as! String*/
						
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
						let dateDieselPlus = dateFormatter.date(from: prixDieselPlusMaj)
						var dateEssencePlus = dateFormatter.date(from: prixEssencePlusMaj)
						let dateGazole = dateFormatter.date(from: prixGazoleMaj)
						let dateSP95E10 = dateFormatter.date(from: prixSP95E10Maj)
						let dateSP95 = dateFormatter.date(from: prixSP95Maj)
						let dateSP98 = dateFormatter.date(from: prixSP98Maj)
						let dateSUP = dateFormatter.date(from: prixSUPMaj)
						let dateEthanol = dateFormatter.date(from: prixEthanolMaj)
						let dateGPL = dateFormatter.date(from: prixGPLMaj)
						
						var nbDaysDieselPlus = " "
						var nbDaysEssencePlus = " "
						var nbDaysGazole = " "
						var nbDaysSP95E10 = " "
						var nbDaysSP95 = " "
						var nbDaysSP98 = " "
						var nbDaysSUP = " "
						var nbDaysEthanol = " "
						var nbDaysGPL = " "
						
						dateFormatter.dateFormat = "yyyy-MM-dd"
						let strAuj = dateFormatter.string(from: Date())
						let auj = dateFormatter.date(from: strAuj)
						
						if(dateDieselPlus != nil){
							let dateStrDieselPlus = dateFormatter.string(from: dateDieselPlus!)
							nbDaysDieselPlus = Calendar.current.dateComponents([.day], from: dateDieselPlus!, to: auj!).day!.description
						}
						if(dateEssencePlus != nil){
							let dateStrEssencePlus = dateFormatter.string(from: dateEssencePlus!)
							nbDaysEssencePlus = Calendar.current.dateComponents([.day], from: dateEssencePlus!, to: auj!).day!.description
						}
						if(dateGazole != nil){
							let dateStrGazole = dateFormatter.string(from: dateGazole!)
							nbDaysGazole = Calendar.current.dateComponents([.day], from: dateGazole!, to: auj!).day!.description
						}
						if(dateSP95E10 != nil){
							let dateStrSP95E10 = dateFormatter.string(from: dateSP95E10!)
							nbDaysSP95E10 = Calendar.current.dateComponents([.day], from: dateSP95E10!, to: auj!).day!.description
						}
						if(dateSP95 != nil){
							let dateStrSP95 = dateFormatter.string(from: dateSP95!)
							nbDaysSP95 = Calendar.current.dateComponents([.day], from: dateSP95!, to: auj!).day!.description
						}
						if(dateSP98 != nil){
							let dateStrSP98 = dateFormatter.string(from: dateSP98!)
							nbDaysSP98 = Calendar.current.dateComponents([.day], from: dateSP98!, to: auj!).day!.description
						}
						if(dateSUP != nil){
							let dateStrSUP = dateFormatter.string(from: dateSUP!)
							nbDaysSUP = Calendar.current.dateComponents([.day], from: dateSUP!, to: auj!).day!.description
						}
						if(dateEthanol != nil){
							let dateStrEthanol = dateFormatter.string(from: dateEthanol!)
							nbDaysEthanol = Calendar.current.dateComponents([.day], from: dateEthanol!, to: auj!).day!.description
						}
						if(dateGPL != nil){
							let dateStrGPL = dateFormatter.string(from: dateGPL!)
							nbDaysGPL = Calendar.current.dateComponents([.day], from: dateGPL!, to: auj!).day!.description
						}
						//}
						
						/* On remplace les , par des . pour avoir une valeur type Float */
						
						let latitude = sLatitude.replacingOccurrences(of: ",", with: ".")
						let longitude = sLongitude.replacingOccurrences(of: ",", with: ".")
						
						self.listeStations.insert(stationObject(idStation: id, nom: nomStation, marque: marque, adresse: adresse, codePostal: codepostal.description, ville: ville, distance: "", latitude: (latitude as NSString).doubleValue, longitude: (longitude as NSString).doubleValue, services: services, prixEssPlus: prixEssencePlus, majEssPlus: nbDaysEssencePlus, ruptureEssPlus: "Non", prixSP95E10: prixSP95E10, majSP95E10: nbDaysSP95E10, ruptureSP95E10: "Non", prixSP95: prixSP95, majSP95: nbDaysSP95, ruptureSP95: "Non", prixSP98: prixSP98, majSP98: nbDaysSP98, ruptureSP98: "Non", prixSUPER: prixSUP, majSUPER: nbDaysSUP, ruptureSUPER: "Non", prixDieselPlus: prixDieselPlus, majDieselPlus: nbDaysDieselPlus, ruptureDieselPlus: "Non", prixDiesel: prixGazole, majDiesel: nbDaysGazole, ruptureDiesel: "Non", prixGPL: prixGPL, majGPL: nbDaysGPL, ruptureGPL: "Non", prixEthanol: prixEthanol, majEthanol: nbDaysEthanol, ruptureEthanol: "Non"), at: 0)
						
						self.labelNbStations.text = self.listeStations.count.description + " stations trouvées."
						completion(1)
					}
				}
			})
		}else{
			// Network connection NOK -> use realm database
			self.listeStations.removeAll()	// Clean the listeStations array before filling it
			let realm = try! Realm()
			if((ville != nil)&&(station == nil)){
				let stations = realm.objects(stationsBDD.self).filter("ville = %@ AND marque = %@",ville,station)
				
				
				
				for stationItem in stations{
					
					let servicesString = stationItem.services.joined(separator: ";")
					
					self.listeStations.insert(stationObject(idStation: stationItem.idStation, nom: stationItem.nomStation, marque: stationItem.marque, adresse: stationItem.adresse, codePostal: stationItem.codePostal.description, ville: stationItem.ville, distance: "", latitude: stationItem.latitude, longitude: stationItem.longitude, services: servicesString, prixEssPlus: " ", majEssPlus: " ", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: " ", ruptureSP95E10: "Non", prixSP95: " ", majSP95: " ", ruptureSP95: "Non", prixSP98: " ", majSP98: " ", ruptureSP98: "Non", prixSUPER: " ", majSUPER: " ", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: " ", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: " ", ruptureDiesel: "Non", prixGPL: " ", majGPL: " ", ruptureGPL: "Non", prixEthanol: " ", majEthanol: " ", ruptureEthanol: "Non"), at: 0)
				}
				self.labelNbStations.text = self.listeStations.count.description + " stations trouvées."
				completion(1)
			}
			if((ville != nil)&&(station != nil)){
				let stations = realm.objects(stationsBDD.self).filter("ville = %@",ville)
			
				for stationItem in stations{
					self.listeStations.insert(stationObject(idStation: stationItem.idStation, nom: stationItem.nomStation, marque: stationItem.marque, adresse: stationItem.adresse, codePostal: stationItem.codePostal.description, ville: stationItem.ville, distance: "", latitude: stationItem.latitude, longitude: stationItem.longitude, services: stationItem.services.joined(separator: ";"), prixEssPlus: " ", majEssPlus: " ", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: " ", ruptureSP95E10: "Non", prixSP95: " ", majSP95: " ", ruptureSP95: "Non", prixSP98: " ", majSP98: " ", ruptureSP98: "Non", prixSUPER: " ", majSUPER: " ", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: " ", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: " ", ruptureDiesel: "Non", prixGPL: " ", majGPL: " ", ruptureGPL: "Non", prixEthanol: " ", majEthanol: " ", ruptureEthanol: "Non"), at: 0)
				}
				completion(1)
			}
			if((CP != nil)&&(station == nil)){
				let stations = realm.objects(stationsBDD.self).filter("codePostal = %@",CP)
				
				for stationItem in stations{
					
					let servicesString = stationItem.services.joined(separator: ";")
					
					self.listeStations.insert(stationObject(idStation: stationItem.idStation, nom: stationItem.nomStation, marque: stationItem.marque, adresse: stationItem.adresse, codePostal: stationItem.codePostal.description, ville: stationItem.ville, distance: "", latitude: stationItem.latitude, longitude: stationItem.longitude, services: servicesString, prixEssPlus: " ", majEssPlus: " ", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: " ", ruptureSP95E10: "Non", prixSP95: " ", majSP95: " ", ruptureSP95: "Non", prixSP98: " ", majSP98: " ", ruptureSP98: "Non", prixSUPER: " ", majSUPER: " ", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: " ", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: " ", ruptureDiesel: "Non", prixGPL: " ", majGPL: " ", ruptureGPL: "Non", prixEthanol: " ", majEthanol: " ", ruptureEthanol: "Non"), at: 0)
				}
				self.labelNbStations.text = self.listeStations.count.description + " stations trouvées."
				completion(1)
			}
			if((CP != nil)&&(station != nil)){
				let stations = realm.objects(stationsBDD.self).filter("codePostal = %@ AND marque = %@",CP,station)
				
				for stationItem in stations{
					
					let servicesString = stationItem.services.joined(separator: ";")
					
					self.listeStations.insert(stationObject(idStation: stationItem.idStation, nom: stationItem.nomStation, marque: stationItem.marque, adresse: stationItem.adresse, codePostal: stationItem.codePostal.description, ville: stationItem.ville, distance: "", latitude: stationItem.latitude, longitude: stationItem.longitude, services: servicesString, prixEssPlus: " ", majEssPlus: " ", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: " ", ruptureSP95E10: "Non", prixSP95: " ", majSP95: " ", ruptureSP95: "Non", prixSP98: " ", majSP98: " ", ruptureSP98: "Non", prixSUPER: " ", majSUPER: " ", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: " ", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: " ", ruptureDiesel: "Non", prixGPL: " ", majGPL: " ", ruptureGPL: "Non", prixEthanol: " ", majEthanol: " ", ruptureEthanol: "Non"), at: 0)
				}
				self.labelNbStations.text = self.listeStations.count.description + " stations trouvées."
				completion(1)
			}
		}
	}
	
	func addStationToFav(station: stationObject){
		let idStation = station.idStation
		
		let realm = try! Realm()
		let itemStation = realm.objects(Station.self).filter("idStation = %@",idStation).first
		
		try! realm.write {
			if itemStation != nil {
					let station = itemStation
					station!.favori = true
					realm.add(station!)
			}else{
				let stat = Station()
				stat.idStation = station.idStation
				stat.marque = station.marque
				stat.nomStation = station.nom
				stat.adresse = station.adresse
				stat.codePostal = Int(station.codePostal)!
				stat.ville = station.ville
				stat.favori = true
				stat.commentaire = ""
				stat.compteur = 0
				stat.latitude = station.latitude
				stat.longitude = station.longitude
				realm.add(stat)
			}
		}
	}
	
	func removeStationFromFav(station: stationObject){
		let idStation = station.idStation
		
		let realm = try! Realm()
		let itemStation = realm.objects(Station.self).filter("idStation = %@",idStation).first
		
		try! realm.write {
			let station = itemStation
			station!.favori = false
			realm.add(station!)
		}
	}
	
	func displayMyStations(){
	
		let realm = try! Realm()
		let stationsList = realm.objects(Station.self).sorted(byKeyPath: "marque")
		
		DispatchQueue.main.async { [weak self] in
			for i in 0..<stationsList.count {
				let station = stationsList[i]
				self!.listeStations.insert(stationObject(idStation: station.idStation, nom: station.nomStation, marque: station.marque, adresse: station.adresse, codePostal: station.codePostal.description, ville: station.ville, distance: " ", latitude: station.latitude, longitude: station.longitude, services: station.services, prixEssPlus: " ", majEssPlus: "", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: "", ruptureSP95E10: "Non", prixSP95: " ", majSP95: "", ruptureSP95: "Non", prixSP98: " ", majSP98: "", ruptureSP98: "Non", prixSUPER: " ", majSUPER: "", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: "", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: "", ruptureDiesel: "Non", prixGPL: " ", majGPL: "", ruptureGPL: "Non", prixEthanol: " ", majEthanol: "", ruptureEthanol: "Non"), at: 0)
			}
			self!.tableViewStations.rowHeight = constants.minRowHeight
			self!.tableViewStations.reloadData()
			self!.labelNbStations.text = (self?.listeStations.count.description)! + " stations trouvées."
			CWProgressHUD.dismiss()
		}
		
		
		
	}
	
	func displayMyFavStations(){
		
		let realm = try! Realm()
		let stationsList = realm.objects(Station.self).filter("favori = true").sorted(byKeyPath: "marque")
		self.listeStations.removeAll()
		DispatchQueue.main.async { [weak self] in
			for i in 0..<stationsList.count {
				let station = stationsList[i]
				self!.listeStations.insert(stationObject(idStation: station.idStation, nom: station.nomStation, marque: station.marque, adresse: station.adresse, codePostal: station.codePostal.description, ville: station.ville, distance: " ", latitude: station.latitude, longitude: station.longitude, services: station.services, prixEssPlus: " ", majEssPlus: "", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: "", ruptureSP95E10: "Non", prixSP95: " ", majSP95: "", ruptureSP95: "Non", prixSP98: " ", majSP98: "", ruptureSP98: "Non", prixSUPER: " ", majSUPER: "", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: "", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: "", ruptureDiesel: "Non", prixGPL: " ", majGPL: "", ruptureGPL: "Non", prixEthanol: " ", majEthanol: "", ruptureEthanol: "Non"), at: 0)
			}
			self!.tableViewStations.rowHeight = constants.minRowHeight
			self!.tableViewStations.reloadData()
			self!.labelNbStations.text = (self?.listeStations.count.description)! + " stations trouvées."
			CWProgressHUD.dismiss()
		}
		
		
		
	}
	
	func displayStationsAroundMe(){
		
		self.searchMode = "stationsAroundMe"
		self.stationSearchState = false
		self.listeStations.removeAll()
		self.latitudeDistance = 2000
		self.longitudeDistance = 2000
		
		// Ask for Authorisation from the User.
		self.locationManager.requestAlwaysAuthorization()
		
		// For use in foreground
		self.locationManager.requestWhenInUseAuthorization()
		
		CWProgressHUD.show(withMessage: "Géolocalisation...")
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.distanceFilter = 200
			locationManager.startUpdatingLocation()
		}
		
		
	}
	/**
		Affiche les stations de la ville
	*/
	func displayStationsOnMyCity(){
		
		self.searchMode = "stationsOnMyCity"
		
		self.listeStations.removeAll()
		self.latitudeDistance = 500
		self.longitudeDistance = 500
		
		// For use in foreground
		self.locationManager.requestWhenInUseAuthorization()
		let message = textStrings.strChargement
		CWProgressHUD.show(withMessage: message)
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
			locationManager.startUpdatingLocation()
			locationManager.requestLocation()
			
		}else{
			let alert = SCLAlertView()
			alert.showError(textStrings.strGeolocationError, subTitle: textStrings.strCheckGPSAuth)
		}
		
	}
	
	/*
	* Utility
	* Fonctions
	*/
	
	func UIColorFromRGB(rgbValue: UInt) -> UIColor {
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	func searchStationsAroundMe(/*completion: @escaping (Int)->Void*/){
		
		if((Utility.connectionState == true)&&(Utility.GPSconnectionState == true)){
			self.stationSearchState = true
			let searchRequest = MKLocalSearch.Request()
			let text = textStrings.strStationService
			searchRequest.naturalLanguageQuery = text
			searchRequest.region = MKCoordinateRegion(center: (self.coordGPS?.coordinate)!, latitudinalMeters: self.latitudeDistance!, longitudinalMeters: self.longitudeDistance!)
		
			let search = MKLocalSearch(request: searchRequest)
			self.listeStations.removeAll()
			search.start {
				response, error in
				guard let response = response else {
					print("Error: \(error?.localizedDescription ?? "Unknown error").")
					return
				}
				print("nb Stations = %@",response.mapItems.count)
				for locationItem in response.mapItems {
		
					let location = CLLocation(latitude: locationItem.placemark.coordinate.latitude, longitude: locationItem.placemark.coordinate.longitude)
		
					/* Distance from the center calculation */
					let rawDistance = (self.coordGPS?.distance(from: location))!/1000
					let distance = String(format: "%.2f", rawDistance)
				
					let marque = locationItem.name
					var number = ""
					var address = ""
					var zipcode = ""
					var city = ""
		
					if(locationItem.placemark.subThoroughfare) != nil{
						number = locationItem.placemark.subThoroughfare!
					}
					if(locationItem.placemark.thoroughfare) != nil {
						address = address + " " + locationItem.placemark.thoroughfare!
					}
					if(locationItem.placemark.postalCode) != nil {
						zipcode = locationItem.placemark.postalCode!
						print("codePostal : %@",zipcode)
					}
					if(locationItem.placemark.locality) != nil {
						city =  locationItem.placemark.locality!
						print("Ville : %@",city)
					}
				
					let strDistance = distance.description
					print("itemDistance ",strDistance)
		
					let results = try! Realm()
						.objects(stationsBDD.self)
						.filterGeoRadius(center: self.coordGPS!.coordinate, radius: self.latitudeDistance!, sortAscending: nil)
					
					let locationItemCoordinates = locationItem.placemark.coordinate.latitude.description + "," + locationItem.placemark.coordinate.longitude.description
		
					let locationName = marque! + " - " + city
		
					let stationObj = stationObject(idStation: "", nom: locationName, marque: marque!, adresse: number + "," + address, codePostal: zipcode, ville: city, distance: distance + " km", latitude: locationItem.placemark.coordinate.latitude, longitude: locationItem.placemark.coordinate.longitude, services: " ", prixEssPlus: " ", majEssPlus: "", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: "", ruptureSP95E10: "Non", prixSP95: " ", majSP95: "", ruptureSP95: "Non", prixSP98: " ", majSP98: "", ruptureSP98: "Non", prixSUPER: " ", majSUPER: "", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: "", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: "", ruptureDiesel: "Non", prixGPL: " ", majGPL: "", ruptureGPL: "Non", prixEthanol: " ", majEthanol: "", ruptureEthanol: "Non")
		
					self.listeStations.append(stationObj)
					self.matchingItems = response.mapItems
					
	//				if(self.listeStations.count >= response.mapItems.count){
	//					search.cancel()
	//				}
				}
				self.locationManager.stopUpdatingLocation()
				self.tableViewStations.rowHeight = constants.minRowHeight
				self.tableViewStations.reloadData()
				self.labelNbStations.text = (self.listeStations.count.description) + " stations trouvées."
				CWProgressHUD.dismiss()
			}
			//completion(1)
		}else{
			self.listeStations.removeAll()
			//let realm = try! Realm()
			let stationsAroundMe = try! Realm().findNearby(type: stationsBDD.self, origin: self.coordGPS!.coordinate, radius: 3000, sortAscending: nil)
			
			for stationItem in stationsAroundMe{
				
				let servicesString = stationItem.services.joined(separator: ";")
				
				self.listeStations.insert(stationObject(idStation: stationItem.idStation, nom: stationItem.nomStation, marque: stationItem.marque, adresse: stationItem.adresse, codePostal: stationItem.codePostal.description, ville: stationItem.ville, distance: "", latitude: stationItem.latitude, longitude: stationItem.longitude, services: servicesString, prixEssPlus: " ", majEssPlus: " ", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: " ", ruptureSP95E10: "Non", prixSP95: " ", majSP95: " ", ruptureSP95: "Non", prixSP98: " ", majSP98: " ", ruptureSP98: "Non", prixSUPER: " ", majSUPER: " ", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: " ", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: " ", ruptureDiesel: "Non", prixGPL: " ", majGPL: " ", ruptureGPL: "Non", prixEthanol: " ", majEthanol: " ", ruptureEthanol: "Non"), at: 0)
			}
			
			self.locationManager.stopUpdatingLocation()
			self.tableViewStations.rowHeight = constants.minRowHeight
			self.tableViewStations.reloadData()
			self.labelNbStations.text = (self.listeStations.count.description) + " stations trouvées."
			
			CWProgressHUD.dismiss()
			
		}
	}
	
	func displayAllStations(){
		
		
		let station = self.stationName
		let CP = Int(self.searchedCP!)
		
		// create searchRef or queryRef you name it
		let stationsRef = Database.database().reference().child("Stations")
		stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
			print(snapshot)
			
			if(snapshot.value is NSNull){
				// NO DATA
				print("– – – Data was not found – – –")
				CWProgressHUD.dismiss()
			}else{
				for stationItem in snapshot.children {
					// DATA FOUND
					/*stationsRef.queryOrdered(byChild: "marque")
					.queryEqual(toValue: "TOTAL ACCESS")
					.observe(.value, with: { snap in*/
					let station_snap = stationItem as! DataSnapshot
					let id = station_snap.key as! String
					let dict = station_snap.value as! NSDictionary
					
					let marque = dict["marque"] as! String
					let nomStation = dict["nomStation"] as! String
					let adresse = dict["adresse"] as! String
					let codepostal = dict["codePostal"] as! Int
					let ville = dict["ville"] as! String
					let pays = dict["pays"] as! String
					let commentaire = dict["commentaire"] as! String
					let latitude = dict["latitude"] as! Float
					let longitude = dict["longitude"] as! Float
					let prixDieselPlus = dict["DieselPlus_prix"] as! String
					let services = dict["services"] as! String
					
					
					
					self.listeStations.insert(stationObject(idStation: id, nom: nomStation, marque: marque, adresse: adresse, codePostal: codepostal.description, ville: ville, distance: "", latitude: Double(latitude), longitude: Double(longitude), services: services, prixEssPlus: " ", majEssPlus: "", ruptureEssPlus: "Non", prixSP95E10: " ", majSP95E10: "", ruptureSP95E10: "Non", prixSP95: " ", majSP95: "", ruptureSP95: "Non", prixSP98: " ", majSP98: "", ruptureSP98: "Non", prixSUPER: " ", majSUPER: "", ruptureSUPER: "Non", prixDieselPlus: " ", majDieselPlus: "", ruptureDieselPlus: "Non", prixDiesel: " ", majDiesel: "", ruptureDiesel: "Non", prixGPL: " ", majGPL: "", ruptureGPL: "Non", prixEthanol: " ", majEthanol: "", ruptureEthanol: "Non"), at: 0)
				}
				self.tableViewStations.rowHeight = constants.minRowHeight
				self.tableViewStations.reloadData()
				self.labelNbStations.text = (self.listeStations.count.description) + " stations trouvées."
				
			}
		})
	}
	
	/*
	* Utility
	* Fonctions
	*/
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
		
		self.currentGPS = locValue
		self.coordGPS = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
		print("locations = \(locValue.latitude) \(locValue.longitude)")
		
		self.bLocalized = true
		
		
		self.currentLatitude = locValue.latitude
		self.currentLongitude = locValue.longitude
		
		if(self.searchMode == "stationsAroundMe"){
			if(self.stationSearchState == false){
				searchStationsAroundMe()
			}
				/*{
					(status) in
				if(status == 1){
						self.tableViewStations.reloadData()
						CWProgressHUD.dismiss()
						return
					}
			}*/
		}
		if(self.searchMode == "stationsOnMyCity"){
			/* Fatal error: Unexpectedly found nil while unwrapping an Optional value */
			if(Utility.connectionState == true){
				if(manager.location != nil){
					CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {
						(placemarks, error) -> Void in
						if error != nil {
							print("Location Error!")
							return
						}
						
						if let pm = placemarks?.first {
							let CP = pm.postalCode
							print("displayStationsOnMyCity = " + CP!)
							self.displaySearchedStations(station: "", CP: CP!, ville: "", completion: {
								(result) in
								if(result == 1){
									manager.stopUpdatingLocation()
									self.tableViewStations.rowHeight = constants.minRowHeight
									self.tableViewStations.reloadData()
									self.labelNbStations.text = (self.listeStations.count.description) + " stations trouvées."
									
									CWProgressHUD.dismiss()
									return
								}
							})
							
						} else {
							let alert = SCLAlertView()
							alert.showError(textStrings.titleAucuneStation, subTitle: textStrings.messageAucuneStation)
						}
					})
				}
			}else{
				if(manager.location != nil){
					manager.stopUpdatingLocation()
					searchStationsAroundMe()
				}
			}
		}
	}
	
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Errors " + error.localizedDescription)
	}
	
}

extension stationsTableViewController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		print("stationsTableViewController : numberOfRowsInSection",self.listeStations.count)
		if(self.listeStations.count == 0){
			print("numberOfRowsInSection = 0")
			
		}
		return self.listeStations.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "stationSearchTableViewCell") as! stationsSearchTableViewCell
		
		
		if(self.senderVC == "AddConsoVC"){
			cell.accessoryType = .none
			cell.carburantsStackView.isHidden = true
			self.tableViewStations.rowHeight = constants.minRowHeight
		}else{
			cell.accessoryType = .disclosureIndicator
			cell.carburantsStackView.isHidden = false
			self.tableViewStations.rowHeight = constants.minRowHeight
		}
		
		let station = self.listeStations[indexPath.row]
		// Configure the cell...
		cell.configureLocationCell(locationId: station.idStation, locationName: station.marque, marque: station.marque, location: station.adresse, codePostal: station.codePostal, ville: station.ville, distance: station.distance, prixEssPlus: station.prixEssPlus, majEssPlus: station.majEssPlus, prixDieselPlus: station.prixDieselPlus, majDieselPlus: station.majDieselPlus, prixGazole: station.prixDiesel, majGazole: station.majDiesel, prixSP95E10: station.prixSP95E10, majSP95E10: station.majSP95E10, prixSP95: station.prixSP95, majSP95: station.majSP95, prixSP98: station.prixSP98, majSP98: station.majSP98, prixSUP: station.prixSUPER, majSUP: station.majSUPER, prixEthanol: station.prixEthanol, majEthanol: station.majEthanol, prixGPL: station.prixGPL, majGPL: station.majGPL)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let loc = self.listeStations[indexPath.row]
		var stat: Station?
		
		if(self.senderVC == "AddConsoVC"){
			self.addConsoVC!.stationSelected(data: loc)
			self.navigationController?.popViewController(animated: true)
			
		}else{
			let stationDetailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "StationDetail") as! StationDetailViewController
			stationDetailVC.station = loc
			
		
			/*let stationDetailsController = StationDetailViewController()
			stationDetailsController.station = loc*/
			
			self.navigationController?.pushViewController(stationDetailVC, animated: true)
		}
		
		
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		var color:UIColor
		var strFavLabel:String
		
		if(self.modeRecherche == 0){
			strFavLabel = NSLocalizedString("Retirer des Favoris", comment: "strRemoveFavori")
			color = UIColor.blue
		}else{
			strFavLabel = NSLocalizedString("Ajouter aux Favoris", comment: "strFavori")
			color = UIColor.red
		}
		
		let favoriButton = UITableViewRowAction(style: .default, title: strFavLabel) { action, index in
			if(self.modeRecherche == 0){
				let station = self.listeStations[indexPath.row]
				print("station id = %@",station.idStation)
				
				let appearance = SCLAlertView.SCLAppearance(
					showCloseButton: false
				)
				let alertVw = SCLAlertView(appearance: appearance)
				alertVw.addButton("Oui", backgroundColor: UIColor.green, textColor: UIColor.white) {
					print("Yes Button tapped")
					self.removeStationFromFav(station: station)
				}
				alertVw.addButton("Non", backgroundColor: UIColor.red, textColor: UIColor.white) {
					print("No Button tapped")
				}
				alertVw.showWarning("Retrait des favoris", subTitle: "Voulez-vous vraiment supprimer cette station des favoris ?")
				
				
			}else{
				let station = self.listeStations[indexPath.row]
				print("station id = %@",station.idStation)
				
				let appearance = SCLAlertView.SCLAppearance(
					showCloseButton: false
				)
				let alertVw = SCLAlertView(appearance: appearance)
				alertVw.addButton("Oui", backgroundColor: UIColor.green, textColor: UIColor.white) {
					print("Yes Button tapped")
					self.addStationToFav(station: station)
					self.tableViewStations.rowHeight = constants.minRowHeight
					self.tableViewStations.reloadData()
					self.labelNbStations.text = (self.listeStations.count.description) + " stations trouvées."
				}
				alertVw.addButton("Non", backgroundColor: UIColor.red, textColor: UIColor.white) {
					print("No Button tapped")
				}
				alertVw.showWarning("Ajout aux favoris", subTitle: "Voulez-vous vraiment ajouter cette station à vos favoris ?")
			}
		}
		favoriButton.backgroundColor = color
		
		return [favoriButton]
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
			if indexPath == lastVisibleIndexPath {
				CWProgressHUD.dismiss()
			}
		}
	}
}

extension CGRect{
	init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
		self.init(x:x,y:y,width:width,height:height)
	}
	
}
extension CGSize{
	init(_ width:CGFloat,_ height:CGFloat) {
		self.init(width:width,height:height)
	}
}
extension CGPoint{
	init(_ x:CGFloat,_ y:CGFloat) {
		self.init(x:x,y:y)
	}
}
public extension String {
	func isNumber() -> Bool {
		return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil && self.rangeOfCharacter(from: CharacterSet.letters) == nil
	}
}

