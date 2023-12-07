//
//  StationsSearchTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 19/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation
import RealmSwift
import Firebase
import FirebaseDatabase
import RSLoadingView
import CWProgressHUD

class StationsSearchTableViewController: UITableViewController, CLLocationManagerDelegate {

    @IBOutlet var tableViewStations: UITableView!
    var matchingItems:[MKMapItem] = []
    var addConsoVC:addConsoVC?
    var locations = [stationObject]()
    var coordGPS:CLLocation?
    var stationName:String?
    var stationAdresse:String?
    var stationVille:String?
    var searchString:String?
    let locationManager = CLLocationManager()
    var car:Car?
    var carName:String?
    var station:Station?
    var oConso:Conso?
    var realm:Realm?
    var coord:CLLocationCoordinate2D?
    var senderVC:String?
    var sv:UIView?
    var localisationOK:Bool?
	var searchedStation:String?
	var searchedAddress:String?
	var searchedVille:String?
	var searchedCP:String?
	var stationCoordGPS:CLLocation?
	var loadingView:RSLoadingView?
	var currentCoordGPS:CLLocation?
	var longitudeDistance:Double?
	var latitudeDistance:Double?
	var waitpopup:CWProgressHUD?
	var currentAddress:String?
	var mklocalSearchRequest:MKLocalSearch.Request?
	var mklocalSearch:MKLocalSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		guard let topWindow = UIApplication.shared.windows.last else {return}
		let overlayView = UIView(frame: topWindow.bounds)
		overlayView.backgroundColor = UIColor.clear
		topWindow.addSubview(overlayView)
		print("viewDidLoad")
		self.loadingView = RSLoadingView(effectType: RSLoadingView.Effect.twins)
		self.loadingView?.speedFactor = 2.0
		self.loadingView?.mainColor = UIColor.green
		self.loadingView?.lifeSpanFactor = 2.0
		self.loadingView!.show(on: overlayView)
		
		/*CWProgressHUD.setStyle(.dark)
		CWProgressHUD.show(withMessage: "Veuillez patienter")*/
		self.searchString = ""
		
        self.localisationOK = false
        checkUsersLocationServicesAuthorization()
		//self.tableView.reloadData()
		/*delayWithSeconds(5) {
			print("delayWithSeconds")
			self.mklocalSearch?.cancel()
		}*/
    }
    
	
    
    func getLocation(forPlaceCalled name: String,
                     completion: @escaping(CLLocation?) -> Void) {
        /*NVActivityIndicatorView(frame: frame, type: type, color: color, padding: padding)
        .startAnimating()
        
        
        
        let yAxis = self.view.center.y
        
        let frame = CGRect(x: (xAxis - 50), y: (yAxis - 50), width: 45, height: 45)
        activityIndicator = NVActivityIndicatorView(frame: frame)
        activityIndicator.type = . ballScale // add your type
        activityIndicator.color = UIColor.red // add your color*/
        //self.view.addSubview(activityIndicator) // or use  webView.addSubview(activityIndicator)
        //ProgressBarNotification.progressBarDisplayer(msg: "Geolocalisation", indicator: true)
        print("getLocation")
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(name) { placemarks, error in
			
            guard error == nil else {
                print("*** Error in \(#function): \(error!.localizedDescription)")
                completion(nil)
				print("getLocation:error")
				let titleNoData = NSLocalizedString("Aucune station", comment: "titleNoData")
				let messageNoData = NSLocalizedString("Votre recherche n'a donné aucun résultat. Veuillez réessayer avec un autre critère de recherche.", comment: "messageNoData")
				let btnOK = NSLocalizedString("OK", comment: "btnOK")
				
				//SweetAlert().showAlert(titleNoData, subTitle: messageNoData, style: AlertStyle.error, buttonTitle:btnOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
				
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            guard let location = placemark.location else {
                print("*** Error in \(#function): placemark is nil")
                completion(nil)
                return
            }
            
            completion(location)
        }
    }

	
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if self.senderVC == "AddConsoVC"
        {
            let indexPath:IndexPath = self.tableViewStations.indexPathForSelectedRow!
            /* On créer l'id de la station à sélectionner */
            let vc = segue.destination as? AddConsoViewController
            
			/* Recherche de l'id dans Firebase */
			let databaseRef = Database.database().reference(withPath: "Stations")
			let dbRef = Database.database().reference()
			
			databaseRef.observe(.value, with: { (snapshot) in
				if let result = snapshot.children.allObjects as? [DataSnapshot] {
					for child in result {
						var orderID = child.key as! String
						print(orderID)
					}
				}
			})
            
            //vc!.idCar = self.car!.idCar
            let station = Station()
            let selectedLocation = locations[indexPath.row]
            station.nomStation = selectedLocation.nom
            station.adresse = selectedLocation.adresse
			station.codePostal = selectedLocation.codePostal
            station.ville = selectedLocation.ville
            //station.coordGPS = selectedLocation.latitude
        
            self.station = station
        }
        
        
        if segue.destination is AddConsoViewController
        {
            let indexPath:IndexPath = self.tableViewStations.indexPathForSelectedRow!
            /* On créer l'id de la station à sélectionner */
            let vc = segue.destination as? AddConsoViewController
            
            /* Envoi de la recherche */
            //vc!.station =
            vc!.car = self.car
            let station = Station()
            let selectedLocation = locations[indexPath.row]
            station.nomStation = selectedLocation.nom
            station.adresse = selectedLocation.adresse
			station.codePostal = selectedLocation.codePostal
            station.ville = selectedLocation.ville
			station.coordGPS = "(" + selectedLocation.latitude.description + ";" + selectedLocation.longitude.description + ")"
            vc!.source = "StationsVC"
            self.station = station
            print("stationsVC","GPS = "+station.coordGPS)
            vc!.station = self.station
            //vc!.station = sender.
            //vc.addConsoVC = self // Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
        }
        
        if segue.destination is editConsoTableViewController
        {
            let indexPath:IndexPath = self.tableViewStations.indexPathForSelectedRow!
            /* On créer l'id de la station à sélectionner */
            let vc = segue.destination as? editConsoTableViewController
            
            /* Envoi de la recherche */
            //vc!.station =
            vc!.carItem = self.car
            let station = Station()
            let consoItem = self.oConso
            
            let selectedLocation = locations[indexPath.row]
            station.nomStation = selectedLocation.nom
            station.adresse = selectedLocation.adresse
			station.codePostal = selectedLocation.codePostal
            station.ville = selectedLocation.ville
			station.coordGPS = "(" + selectedLocation.latitude.description + ";" + selectedLocation.longitude.description + ")"
            
            self.station = station
            let realm = try! Realm()
            try! realm.write {
                consoItem!.adresseStation = selectedLocation.nom
                consoItem!.CPStation = selectedLocation.codePostal
                consoItem!.villeStation = selectedLocation.ville
                realm.add(consoItem!)
            }
            vc!.station = self.station
            vc!.consoItem = consoItem
            vc!.source = "StationsVC"
        }
    }
    
    func animateTable() {
        self.tableViewStations.reloadData()
        print("animateTable")
        let cells = tableViewStations.visibleCells
        let tableHeight: CGFloat = tableViewStations.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
    
    @IBAction func goBackToOneButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToVC1", sender: self)
    }
	
	
	/**
	->>> FONCTIONS <<<-
	**/
	
	/* Construction de l'adresse */
	func buildAddress(){
		print("buildAddress")
		print("searchString-debut buildAddress",self.searchString)
		let addressArray = self.currentAddress?.split(separator: ",")
		
		if(self.stationName == "")||(self.stationName == nil){
			let titleNoStationSelected = NSLocalizedString("Aucune station sélectionnée", comment: "titleNoStationSelected")
			let messageNoStationSelected = NSLocalizedString("Vous n'avez pas sélectionné de station. Relancez votre recherche.", comment: "messageNoStationSelected")
			let btnOK = NSLocalizedString("OK", comment: "btnOK")
			
			SweetAlert().showAlert(titleNoStationSelected, subTitle: messageNoStationSelected, style: AlertStyle.customImage(imageFile: "icon_station"), buttonTitle:btnOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
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
		
		/*if(self.searchedVille == nil)||(self.searchedVille == ""){
			self.searchedVille = addressArray![3].description
			self.searchString = self.searchString! + " " + self.searchedVille!
		}*/
		
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
		/// Check if user has authorized Total Plus to use Location Services
		//if CLLocationManager.locationServicesEnabled() {
		let titleEnableGPS = NSLocalizedString("Autorisation GPS", comment: "titleEnableGPS")
		let messageEnableGPS = NSLocalizedString("L'app AutoConso a besoin d'accéder à votre localisation. Activer les permissions de localisation dans le menu Réglages de votre iPhone", comment: "messageEnableGPS")
		let settingsButton = NSLocalizedString("Réglages", comment: "settingsButton")
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
			//switchAutoTaxDetection.isOn = false
			
			SweetAlert().showAlert(titleEnableGPS, subTitle: messageEnableGPS, style: AlertStyle.customImage(imageFile: "icon_location"), buttonTitle:settingsButton, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
			{ action in
				guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
					return
				}
				if UIApplication.shared.canOpenURL(settingsUrl) {
					UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						print("Settings opened: \(success)")
					})
				}
				
			}
			
			break
			
		case .authorizedWhenInUse, .authorizedAlways:
			// Enable features that require aaaation services here.
			print("Full Access")
			self.localisationOK = true
			buildAddress()
			//ARSLineProgress.
			getCoordinatesFromAddress(Address: self.searchString!)
			performSearchRequest()
			CWProgressHUD.dismiss()
			print("On sort de authorizedWhenInUse")
			break
		}
		/*}else{
		
		}*/
	}
	
	/* Cette fonction lance une recherche des stations */
	func performSearchRequest() {
		print("performSearchRequest")
		self.mklocalSearchRequest = MKLocalSearch.Request()
		
		let locationManager = CLLocationManager()
		//let lieu = self.stationName! + " " + self.stationAdresse! + " " + self.stationVille!
		
		/*getLocation(forPlaceCalled: self.searchString!) { location in
			guard let location = location else {
				print("getLocation")
				let titleNoData = NSLocalizedString("Aucune station", comment: "titleNoData")
				let messageNoData = NSLocalizedString("Votre recherche n'a donné aucun résultat. Veuillez réessayer avec un autre critère de recherche.", comment: "messageNoData")
				let btnOK = NSLocalizedString("OK", comment: "btnOK")
				print("pas de resultat")
				//SweetAlert().showAlert(titleNoData, subTitle: messageNoData, style: AlertStyle.error, buttonTitle:btnOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
				//ARSLineProgress.showFail()
				return
				
			}
		}*///ARSLineProgress.showSuccess()
		var coord:CLLocation?
		
		if self.stationCoordGPS != nil {
			coord = self.stationCoordGPS
		}else{
			coord = self.currentCoordGPS
		}
		
		print(self.searchString)
		
		let center = CLLocationCoordinate2D(latitude: (coord?.coordinate.latitude)!, longitude:(coord?.coordinate.longitude)!)
		print("Coordinates",coord?.coordinate)
		
		let region = MKCoordinateRegion(center: coord!.coordinate, latitudinalMeters: self.latitudeDistance!, longitudinalMeters: self.longitudeDistance!)
			
		let naturalLanguageQuery = self.searchString!
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
					
				let distanceBrute = (coord?.distance(from: loc))!/1000
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
				let location = stationObject(idStation: "", nom: nom!, marque: "-", adresse: adresse, codePostal: codePostal, ville: Ville, distance: strDistance + " km", latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, services: "-", prixEssPlus: "0.00", majEssPlus: "", ruptureEssPlus: "Non", prixSP95E10: "0.00", majSP95E10: "", ruptureSP95E10: "Non", prixSP95: "0.00", majSP95: "", ruptureSP95: "Non", prixSP98: "0.00", majSP98: "", ruptureSP98: "Non", prixSUPER: "0.00", majSUPER: "", ruptureSUPER: "Non", prixDieselPlus: "0.00", majDieselPlus: "", ruptureDieselPlus: "Non", prixDiesel: "0.00", majDiesel: "", ruptureDiesel: "Non", prixGPL: "0.00", majGPL: "", ruptureGPL: "Non", prixEthanol: "0.00", majEthanol: "", ruptureEthanol: "Non")
				self.locations.append(location)
				self.matchingItems = response.mapItems
				self.tableView.reloadData()
			}
		}
	}

	
	/* Cette fonction renvoie les coordonnées GPS d'une adresse donnée */
	func getCoordinateFrom(address: String, completion: @escaping(_ coordinate: CLLocationCoordinate2D?, _ error: Error?) -> () ) {
		CLGeocoder().geocodeAddressString(address, completionHandler: { (placemarks, error) -> Void in
			if error != nil {
				print(error!)
				return
			}
			if placemarks!.count > 0 {
				let placemark = placemarks?[0]
				let location = placemark?.location
				//self.coordinates = location?.coordinate
				
				if let subAdminArea = placemark?.subAdministrativeArea {
					//self.address.county = subAdminArea
				}
			}
		})
	}
	
	/* Cette fonction renvoie les coordonnées GPS d'une adresse donnée */
	func getCoordinatesFromAddress(Address:String){
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(Address) { (placemarks, error) in
			if let placemarks = placemarks {
				if placemarks.count != 0 {
					/*let annotation = CLPlacemark(placemark: placemarks.first!)
					self.mapView.addAnnotation(annotation)*/
					let coordinates = placemarks.first!.location
					print("getCoordinatesFromAddress",coordinates?.description)
					self.stationCoordGPS = coordinates
				}
			}
		}
	}
	
	/* Fonctions utilitaires */
	
	func UIColorFromRGB(rgbValue: UInt) -> UIColor {
		return UIColor(
			red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
	
	override func viewWillDisappear(_ animated: Bool){
		super.viewWillAppear(true)
		//fadeOut()
		//self.mklocalSearch?.cancel()
		self.loadingView?.hide()
		RSLoadingView.hideFromKeyWindow()
	}
	
	func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
		DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
			completion()
		}
	}
}

extension StationsSearchTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("LocationSearchTable : numberOfRowsInSection",matchingItems.count)
        if(matchingItems.count == 0){
			print("numberOfRowsInSection = 0")
			
		}
        return matchingItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "stationSearchTableViewCell") as! stationsSearchTableViewCell
        
        if(locations.count == 0){
			cell.configureLocationCell(locationId: "", locationName: "Aucun résultat à afficher", marque: "", location: "Toucher pour revenir à l'écran précédent", codePostal: "", ville: "", distance: "", prixEssPlus: "", majEssPlus: "",  prixDieselPlus: "", majDieselPlus: "", prixGazole: "", majGazole: "", prixSP95E10: "", majSP95E10: "", prixSP95: "", majSP95: "", prixSP98: "", majSP98: "", prixSUP: "", majSUP: "", prixEthanol: "", majEthanol: "", prixGPL: "", majGPL: "")
			let titleNoData = NSLocalizedString("Aucune station", comment: "titleNoData")
			let messageNoData = NSLocalizedString("Votre recherche n'a donné aucun résultat. Veuillez réessayer avec un autre critère de recherche.", comment: "messageNoData")
			let btnOK = NSLocalizedString("OK", comment: "btnOK")
			
			SweetAlert().showAlert(titleNoData, subTitle: messageNoData, style: AlertStyle.error, buttonTitle:btnOK, buttonColor:self.UIColorFromRGB(rgbValue: 0xD0D0D0))
        }else{
            //performSearchRequest() 
            let location = locations[indexPath.row]
            // Configure the cell...
			cell.configureLocationCell(locationId: location.idStation, locationName: location.marque, marque: location.marque, location: location.adresse, codePostal: location.codePostal, ville: location.ville, distance: location.distance, prixEssPlus: location.prixEssPlus, majEssPlus: "", prixDieselPlus: location.prixDieselPlus, majDieselPlus: "", prixGazole: location.prixDiesel, majGazole: "", prixSP95E10: location.prixSP95E10, majSP95E10: "", prixSP95: location.prixSP95, majSP95: "", prixSP98: location.prixSP98, majSP98: "", prixSUP: "", majSUP: "", prixEthanol: "", majEthanol: "", prixGPL: "", majGPL: "")
        }
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let loc = locations[indexPath.row]
		//print("Nom : " + loc + ", coordGPS : " + loc.coordGPS)
		var stat: Station?
		
		if let myImage = UIImage(named: stat!.marque) {
			loc.image.image = UIImage(named: stat!.marque)
        }
        else {
            loc.image.image = UIImage(named: "icon_fuels")
        }
		
		self.addConsoVC!.stationSelected(data: loc)
		self.navigationController?.popViewController(animated: true)
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
			if indexPath == lastVisibleIndexPath {
				
			}
		}
	}
}

extension UITableViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
		let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}


