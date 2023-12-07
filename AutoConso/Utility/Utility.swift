//
//  Utility.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 30/08/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase
import FirebaseDatabase
import CoreLocation
import SCLAlertView
import SystemConfiguration

struct addressStruct{
	var numero:String
	var adresse:String
	var codepostal:String
	var ville:String
}

class Utility {
	
	static var connected:Bool = false
	static var locationManager:CLLocationManager = CLLocationManager()
	static var currentCoordinates = CLLocation()
	static var convertedLatitude:Double?
	static var convertedLongitude:Double?
	static var userPseudo:String?
	static var userID:String?
	static var userCountry:String?
	static var userEmail:String?
	static var userProfile:String?
	static var stringsDict:Dictionary<String, AnyObject>?
	static var connectionTimeOut:Int = 0
	static var connectionState:Bool = false			/* This boolean manages Internet connection state */
	static var GPSconnectionState:Bool = false		/* This boolean manages GPS connection state */
	static var carLastKM:Int?
	static var carDateAchat:Date?
	
	static func getData() -> [String:String] {
		// do some operations
		return ["someData" : "someData"]
	}
	
	static func checkInternetConnection(completion: @escaping (Bool)-> Void){
		let connectedRef = Database.database().reference(withPath: ".info/connected")
		connectedRef.observe(.value, with: { snapshot in
			if snapshot.value as? Bool ?? false {
				completion(true)
			} else {
				completion(false)
			}
		})
	}
	
	static func getCurrentCoordinates(completion: @escaping (Int)-> Void){
		var currentLocation: CLLocation!
		var locManager = CLLocationManager()
		
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		
		if(self.locationManager.location != nil){
			currentLocation = self.locationManager.location
			self.currentCoordinates = currentLocation
			completion(1)
		}
	}
	static func getCarKM(car:Car)-> Int{
		let realm = try! Realm()
		let carkm = car.kilometrage
		return carkm
	}
	static func getLastCarKM(car:Car)-> Int{
		let realm = try! Realm()
		
		let consos = realm.objects(Conso.self).filter("idCar = %@",car.idCar).sorted(byKeyPath: "carKilometrage", ascending: true)
		
		if(consos.count == 0){
			let carkm = car.kilometrage
			return carkm
		}else{
			let carLastKM = consos.last!.carKilometrage
			print(carLastKM)
			return carLastKM
		}
	}
	static func getCarDateAchat(car:Car)-> Date{
		let realm = try! Realm()
		let carDateAchat = car.dateAchat
		return carDateAchat
	}
	static func getCarEnergie(car:Car)-> String{
		let realm = try! Realm()
		return car.energy
	}
	static func SCLalertVw(titre:String, message:String, buttonOK:Bool, buttonCancel:Bool){
		let appearance = SCLAlertView.SCLAppearance(
			showCloseButton: false
		)
		let popup = SCLAlertView(appearance: appearance)
		
		if(buttonOK == true){
			popup.addButton("OK", backgroundColor: UIColor.gray, textColor: UIColor.white){
			}
		}
		popup.showWarning(textStrings.titleAdresseInexistante, subTitle: textStrings.messageAdresseInexistante)
	}
	
	static func getCoordinatesFromAddress(address:String, completion: @escaping (CLLocation)->Void){
		/**/
		print("getCoordinatesFromAddress: Address = %@",address)
		let geoCoder = CLGeocoder()
		var tCoordinates:CLLocation = CLLocation(latitude: 0.0, longitude: 0.0)
		geoCoder.geocodeAddressString(address) { (placemarks, error) in
			guard
				let placemarks = placemarks,
				let location = placemarks.first?.location
				else {
					// handle no location found
					completion(tCoordinates)
					return
			}
			let latitude = location.coordinate.latitude
			let longitude = location.coordinate.longitude
			print("latitude = %@",latitude)
			print("longitude = %@",longitude)
			
			let tCoordinates = CLLocation(latitude: latitude, longitude: longitude)
			
			completion(tCoordinates)
			// Use your location
		}
	}
	
	/*
	*
	* Converts address to GPS location
	*/
	func convAddress2Coord(address:String, completion: @escaping (_ addressFound: Bool) -> Void){
		//let address = "1 Infinite Loop, Cupertino, CA 95014"
		
		let geoCoder = CLGeocoder()
		geoCoder.geocodeAddressString(address) { (placemarks, error) in
			guard
				let placemarks = placemarks,
				let location = placemarks.first?.location
				else {
					// handle no location found
					print("No location found")
					
					/*let buttonOK = NSLocalizedString("OK", comment: "buttonOK")
					
					let appearance = SCLAlertView.SCLAppearance(
						showCloseButton: false
					)
					let popup = SCLAlertView(appearance: appearance)
					
					popup.addButton(buttonOK, backgroundColor: UIColor.gray, textColor: UIColor.white){
					}
					popup.showWarning(titleAdresseInexistante, subTitle: messageAdresseInexistante)
					
					completion(false)*/
					return
			}
			//self.convertedLatitude = location.coordinate.latitude
			//self.convertedLongitude = location.coordinate.longitude
			// Use your location
			completion(true)
		}
	}
	
	static func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
	{
		manager.stopUpdatingLocation()
		//--- CLGeocode to get address of current location ---//
		CLGeocoder().reverseGeocodeLocation(manager.location!, completionHandler: {(placemarks, error)->Void in
			if (error != nil)
			{
				print("Reverse geocoder failed with error" + error!.localizedDescription)
				return
			}
			
			if placemarks!.count > 0
			{
				let pm = placemarks![0] as CLPlacemark
				print(pm)
			}
			else
			{
				print("Problem with the data received from geocoder")
			}
		})
	}
	
	static func getAdressFromLocation(loc:CLLocation, completion: @escaping (_ numero:String, _ adresse: String, _ codePostal: String, _ ville: String)-> Void){
		//var address: String = ""
		let street = ""
		let zip = ""
		let city = ""
		var complete:Bool?
		
		let geoCoder = CLGeocoder()
		var addressArray:[String]
		geoCoder.reverseGeocodeLocation(loc, completionHandler: { (placemarks, error) -> Void in
			var addressArray = [NSString]()
			// Place details^ùm
			var placeMark: CLPlacemark!
			placeMark = placemarks?[0]
			
			if(placeMark != nil){
				if let number = placeMark.addressDictionary!["SubThoroughfare"] as? String {
					print(number)
					let numero = number.description
					//addressStruct. = numero
					//self.adresseVehicule.text = street as String
				}
				
				// Street address
				if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
					print(street)
					addressArray.append(street)
					//addressStruct.adresse = street.description
					//self.adresseVehicule.text = street as String
				}
				
				// Zip code
				if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
					print(zip)
					addressArray.append(zip)
					//addressStruct.codepostal = zip.description
					//address = address + ", " + (zip as String)
					//self.CPVilleVehicule.text = (zip as String)
				}
				
				// City
				if let city = placeMark.addressDictionary!["City"] as? NSString {
					print(city)
					addressArray.append(city)
					//addressStruct.ville = city
					//address = address + " " + (city as String)
					//self.CPVilleVehicule.text = self.CPVilleVehicule.text! + " " + (city as String)
				}
			}
			if(addressArray.count == 4){
				completion(addressArray[0] as String, addressArray[1] as String, addressArray[2] as String, addressArray[3] as String)
			}
			if(addressArray.count == 3){
				completion("", addressArray[0] as String, addressArray[1] as String, addressArray[2] as String)
			}
		})
	}
	
	static func replaceSpecialCharsFromString(text: String) -> String {
		let str1 = text.replacingOccurrences(of: "é", with: "e")
		let str2 = str1.replacingOccurrences(of: "è", with: "e")
		let str3 = str2.replacingOccurrences(of: "ê", with: "e")
		let str4 = str3.replacingOccurrences(of: "ë", with: "e")
		let str5 = str4.replacingOccurrences(of: "ö", with: "o")
		let str6 = str5.replacingOccurrences(of: "ù", with: "u")
		let str7 = str6.replacingOccurrences(of: "ô", with: "o")
		let str8 = str7.replacingOccurrences(of: "î", with: "i")
		let str9 = str8.replacingOccurrences(of: "ï", with: "i")
		
		return str9
	}
	
	static func getUTCTimestamp() -> String {
		//let timestamp = Date.init(timeIntervalSince1970: 1/1000).description
		let date = Date()
		// "Nov 2, 2016, 4:48 AM" <-- local time
		
		var formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		let defaultTimeZoneStr = formatter.string(from: date)
		// "2016-11-02 04:48:53 +0800" <-- same date, local with seconds and time zone
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		let utcTimeZoneStr = formatter.string(from: date)
		// "2016-11-01 20:48:53 +0000" <-- same date, now in UTC
		return utcTimeZoneStr
	}
	static func getCurrentDate() -> Date {
		//let timestamp = Date.init(timeIntervalSince1970: 1/1000).description
		let date = Date()
		// "Nov 2, 2016, 4:48 AM" <-- local time
		
		var formatter = DateFormatter()
		formatter.dateFormat = "dd/mm/yyyy"
		let dateStr = formatter.string(from: date)
		
		return formatter.date(from: dateStr)!
	}
	
	static func convStationBDDToStation(stationbdd: stationsBDD) -> Station {
		let idStation = stationbdd.idStation
		var station:Station = Station()
		
		station.idStation = stationbdd.idStation
		station.nomStation = stationbdd.nomStation
		station.marque = stationbdd.marque
		station.adresse = stationbdd.adresse
		station.codePostal = stationbdd.codePostal
		station.ville = stationbdd.ville
		station.latitude = stationbdd.latitude
		station.longitude = stationbdd.longitude
		
		return station
	}
	
	static func convStationObectToStation(stationObj: stationObject) -> Station {
		let idStation = stationObj.idStation
		var station:Station = Station()
		
		station.idStation = stationObj.idStation
		station.nomStation = stationObj.nom
		station.marque = stationObj.marque
		station.adresse = stationObj.adresse
		station.codePostal = stationObj.codePostal
		station.ville = stationObj.ville
		station.latitude = stationObj.latitude
		station.longitude = stationObj.longitude
		
		return station
	}
	
	static func convStationBDDToStationObject(stationBDD: stationsBDD) -> stationObject {
		var stationObjectItem:stationObject = stationObject(idStation: stationBDD.idStation, nom: stationBDD.nomStation, marque: stationBDD.marque, adresse: stationBDD.adresse, codePostal: stationBDD.codePostal, ville: stationBDD.ville, distance: "-", latitude: stationBDD.latitude, longitude: stationBDD.longitude, services: stationBDD.services.joined(separator: "; "), prixEssPlus: "", majEssPlus: "", ruptureEssPlus: "", prixSP95E10: "", majSP95E10: "", ruptureSP95E10: "", prixSP95: "", majSP95: "", ruptureSP95: "", prixSP98: "", majSP98: "", ruptureSP98: "", prixSUPER: "", majSUPER: "", ruptureSUPER: "", prixDieselPlus: "", majDieselPlus: "", ruptureDieselPlus: "", prixDiesel: "", majDiesel: "", ruptureDiesel: "", prixGPL: "", majGPL: "", ruptureGPL: "", prixEthanol: "", majEthanol: "", ruptureEthanol: "")
		
		return stationObjectItem
	}
	
	/* Sends the user informations based on UserDefaults */
	static func getUserInformation() -> Void {
		self.userID = UserDefaults.standard.string(forKey: "userId")
		self.userPseudo = UserDefaults.standard.string(forKey: "usrPseudo")
		self.userEmail = UserDefaults.standard.string(forKey: "usrEmail")
		self.userCountry = UserDefaults.standard.string(forKey: "usrCountry")
		self.userProfile = UserDefaults.standard.string(forKey: "usrProfil")
	}
	
	typealias boolCompletionHandler = (_ success:Bool) -> Void
	
	static func isConnectedToNetwork(customCompletionHandler:@escaping boolCompletionHandler)->Void{
		
		let url = NSURL(string: "https://google.com/")
		let request = NSMutableURLRequest(url: url! as URL)
		request.httpMethod = "HEAD"
		request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
		request.timeoutInterval = 7.0
		let session = URLSession.shared
		
		var response:URLResponse?
		
		session.dataTask(with: request as URLRequest, completionHandler: {(data, response, error) in
			print("data \(data)")
			print("response \(response)")
			print("error \(error)")
			
			if let httpResponse = response as? HTTPURLResponse {
				print("httpResponse.statusCode \(httpResponse.statusCode)")
				if httpResponse.statusCode == 200 {
					connectionState = true
					customCompletionHandler(connectionState)
					//Status = true
				}
			}
			
			if error != nil {
				connectionState = false
				customCompletionHandler(connectionState)
			}
			
		}).resume()
	}
	static func isConnectedToFirebase(completion: @escaping (Bool)-> Void){
		
		var Status:Bool?
		let connectedRef = Database.database().reference(withPath: ".info/connected")
		connectedRef.observe(.value, with: {snapshot in
			
			let connected = snapshot.value as? Bool
			if connected != nil && connected! {
				// Firebase connection OK
				connectionState = true
				completion(true)
			} else {
				// Firebase connection NOK
				self.connectionTimeOut+=1
				connectionState = false
				completion(false)
			}
		})
	}
	
	static let sharedInstance = Utility()
	
	lazy var localizableDictionary: NSDictionary! = {
		if let path = Bundle.main.path(forResource: "appStrings", ofType: "plist") {
			return NSDictionary(contentsOfFile: path)
		}
		fatalError("Localizable file NOT found")
	}()
	
	static func parseAppStrings() -> [String: AnyObject]? {
		
		// check if plist data available
		guard let plistURL = Bundle.main.url(forResource: "appStrings", withExtension: "plist"),
			let data = try? Data(contentsOf: plistURL)
			else {
				return nil
		}
		
		// parse plist into [String: Anyobject]
		guard let plistDictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: AnyObject] else {
			return nil
		}
		
		return plistDictionary
	}
}


extension String {
	func capitalizingFirstLetter() -> String {
		return prefix(1).uppercased() + self.lowercased().dropFirst()
	}
	mutating func capitalizeFirstLetter() {
		self = self.capitalizingFirstLetter()
	}
	/*var localized: String {
		/*  */
		return NSLocalizedString(self, comment: "")
	}*/
	/*var localized: String {
		return Utility.sharedInstance.localize(string: self)
	}*/
}

extension StringProtocol {
	var firstUppercased: String {
		return prefix(1).uppercased() + self.lowercased().dropFirst()
	}
	var firstCapitalized: String {
		return prefix(1).capitalized + dropFirst()
	}
}
