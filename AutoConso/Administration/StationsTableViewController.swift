//
//  StationsTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 24/03/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

struct StationItem {
	var idStation: String
	var stationName: String
	var stationAdresse: String
	var stationCP: String
	var stationVille: String
	var marque: String
	var latitude: Double
	var longitude: Double
	var services: [String]
	var horaires: [Jour]
	var carburants: [Carburant]
}

struct Carburant {
	var nomCarburant: String
	var userPseudo: String
	var dateMaj: String
	var prix: Double
	var rupture: Bool
}

class Jour {
	var jour: String = ""
	var ouverture: String = ""
	var fermeture: String = ""
	var dateMaj: String = ""
	var userPseudo: String = ""
}


import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import CSV
import CWProgressHUD
import SWXMLHash
import RealmSwift
import SCLAlertView
import FirebaseDatabase

class StationsTableViewController: UIViewController, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
	
	var stationItem:Station?
	var stationArray:[Station]?
	var internalStationArray:[Station]?
	var internalStations:Results<stationsBDD>!
	var dbRef:DatabaseReference!
	
	var stations: [StationItem] = []
	var elementName: String = String()
	var idStation = String()
	var stationVille = String()
	var stationAdresse = String()
	var stationCP = String()
	var stationName = String()
	var marque = String()
	var latitude = Double()
	var longitude = Double()
	var services = [String]()
	var horaires = [Jour]()
	var carburants = [Carburant]()
	var jourObj:Jour?
	var index:Int = 0
	var stationObjects: Results<stationsBDD>!
	var objStations: [stationsBDD] = []
	
	@IBOutlet var tableViewStations: UITableView!
	@IBAction func btnImporter(_ sender: UIBarButtonItem) {
		
		
		
		let optionMenu = UIAlertController(title: nil, message: "Que voulez-vous faire ?", preferredStyle: .actionSheet)
		let FeedFirebaseAction = UIAlertAction(title: "Alimenter la base Firebase", style: .default, handler:
		{
			(alert: UIAlertAction!) -> Void in
			self.updatePricesFromXML()
			print("Saved")
		})
		let updatePricesAction = UIAlertAction(title: "Mettre à jour les prix de carburants", style: .default, handler:
		{
			(alert: UIAlertAction!) -> Void in
			self.updatePricesFromXML()
			print("Deleted")
		})
		
		let realmFeedAction = UIAlertAction(title: "Mettre à jour la base interne", style: .default, handler:
		{
			(alert: UIAlertAction!) -> Void in
			print("Cancelled")
		})
		let updateStationNameAction = UIAlertAction(title: "Mettre à jour les noms de station", style: .default, handler:
		{
			(alert: UIAlertAction!) -> Void in
			print("Cancelled")
			self.updateStationsMarqueFromCSV()
		})
		let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler:
		{
			(alert: UIAlertAction!) -> Void in
			print("Cancelled")
		})
		optionMenu.addAction(FeedFirebaseAction)
		optionMenu.addAction(updatePricesAction)
		optionMenu.addAction(realmFeedAction)
		optionMenu.addAction(updateStationNameAction)
		optionMenu.addAction(cancelAction)
		self.present(optionMenu, animated: true, completion: nil)
		
//		CWProgressHUD.dismiss()
//		let alertView = SCLAlertView() //Replace the IconImage text with the image name
//		alertView.showSuccess("Fin de l'opération", subTitle: "La mise à jour est terminée !")
		
		self.tableViewStations.reloadData()
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tableViewStations.delegate = self as! UITableViewDelegate
		self.tableViewStations.dataSource = self as! UITableViewDataSource
		
		self.stationItem = Station()
		self.stationArray = [Station]()
		
		getRealmStations()
		
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "StationCell", for: indexPath) as! StationsTableViewCell
		
		let stationObj = self.objStations[indexPath.row]
		let stationMarque = stationObj.marque
		// Configure the cell...
		cell.labelNomStation.text = stationObj.nomStation
		cell.labelAdresse.text = stationObj.adresse
		cell.labelCodePostalVille.text = stationObj.codePostal.description + " " + stationObj.ville
		
		if (UIImage(named: stationMarque.uppercased()) != nil) {
			let fileName = stationMarque.uppercased()
			cell.ImageViewStationMarque?.image = UIImage(named: fileName)
		}
		else {
			cell.ImageViewStationMarque?.image = UIImage(named: "icon_fuels")
		}
		
		
		
		
		/*if indexPath.row == self.stationArray?.count {
			CWProgressHUD.dismiss()
		}*/
		//let stationImage = UIImage(data: self.carObjects[indexPath.row].data! as Data)
		//cell.ImageViewStationMarque?.image = carImage
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
		// Add animations here
		cell.alpha = 0
		
		UIView.animate(
			withDuration: 0.1,
			delay: 0.01 * Double(indexPath.row),
			animations: {
				cell.alpha = 1
		})
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.objStations.count
	}
	
	override func viewWillAppear(_ animated: Bool){
		super.viewWillAppear(true)
	}
	
	override func viewWillDisappear(_ animated: Bool){
		super.viewWillAppear(true)
	}
	
	/* Utility functions */
	func getSearchResultList(){
		self.stationItem = Station()
		self.stationArray = [Station]()

		/* Firebase Connection */
		let ref = Database.database().reference().child("Stations").queryOrdered(byChild: "nomStation").queryEqual(toValue: "AVIA Antony")
		
		ref.observe(.value, with: { snapshot in
			
			let snapshotValue = snapshot.value as! NSDictionary
			let text = snapshotValue["nomStation"] as! String
			let sender = snapshotValue["ville"] as! String
			
			let nom = snapshotValue["nomStation"] as! String
			let marque = snapshotValue["marque"] as! String
			let adresse = snapshotValue["adresse"] as! String
			let codepostal = snapshotValue["codePostal"] as! String
			let ville = snapshotValue["ville"] as! String
			let pays = snapshotValue["pays"] as! String
			let coordGPS = snapshotValue["coordGPS"] as! String
			let commentaire = snapshotValue["commentaire"] as! String
			
			self.stationItem!.nomStation = nom
			self.stationItem!.adresse = adresse
			self.stationItem!.codePostal = codepostal
			self.stationItem!.ville = ville
			self.stationItem!.marque = marque
			self.stationItem!.pays = pays
			self.stationItem!.commentaire = commentaire
			self.stationItem!.coordGPS = coordGPS
			
			self.stationArray?.append(self.stationItem!)
			self.tableViewStations.reloadData()
		})
	}
	func getRealmStations(){
		let realm = try! Realm()
		self.stationObjects = realm.objects(stationsBDD.self).sorted(byKeyPath: "codePostal")
		self.objStations = Array(self.stationObjects)
		self.tableViewStations.reloadData()
		print("getRealmStations")
	}

	func getStationsList(){
		
		self.stationItem = Station()
		self.stationArray = [Station]()
		
		/* Firebase Connection */
		let ref = Database.database().reference().child("Stations")
		
		ref.observe(.value, with: { snapshot in
			
			var stationItems = [DataSnapshot]()
			
			for item in snapshot.children {
				stationItems.append(item as! DataSnapshot)
			}
			/*if snapshot.childrenCount > 0 {
				
				// Clearing the stationArray
				self.stationArray?.removeAll()
				
				let snapshotValue = snapshot.value as! NSDictionary
				
				let nom = snapshotValue["nomStation"] as! String
				let marque = snapshotValue["marque"] as! String
				let adresse = snapshotValue["adresse"] as! String
				let codepostal = snapshotValue["codePostal"] as! String
				let ville = snapshotValue["ville"] as! String
				let pays = snapshotValue["pays"] as! String
				let coordGPS = snapshotValue["coordGPS"] as! String
				let commentaire = snapshotValue["commentaire"] as! String
				
				self.stationItem!.nomStation = nom
				self.stationItem!.adresse = adresse
				self.stationItem!.codePostal = codepostal
				self.stationItem!.ville = ville
				self.stationItem!.marque = marque
				self.stationItem!.pays = pays
				self.stationItem!.commentaire = commentaire
				self.stationItem!.coordGPS = coordGPS
				
				self.stationArray?.append(self.stationItem!)
			}*/
			/*let snapshotValue = snapshot.value as! NSDictionary
			let key = snapshotValue[0]
			
			let refStation = ref.child(key)
			
			refStation.observe(.value, with: {snap in
				
				let snapValue = snap.value as! NSDictionary
				
				let text = snapValue["nomStation"] as! String
				let sender = snapValue["ville"] as! String
				
				let nom = snapValue["nomStation"] as! String
				let marque = snapValue["marque"] as! String
				let adresse = snapValue["adresse"] as! String
				let codepostal = snapValue["codePostal"] as! String
				let ville = snapValue["ville"] as! String
				let pays = snapValue["pays"] as! String
				let coordGPS = snapValue["coordGPS"] as! String
				let commentaire = snapValue["commentaire"] as! String
			
				self.stationItem!.nomStation = nom
				self.stationItem!.adresse = adresse
				self.stationItem!.codePostal = codepostal
				self.stationItem!.ville = ville
				self.stationItem!.marque = marque
				self.stationItem!.pays = pays
				self.stationItem!.commentaire = commentaire
				self.stationItem!.coordGPS = coordGPS
				
				self.stationArray?.append(self.stationItem!)
				self.tableViewStations.reloadData()
			})*/
		})
	}
	
    func loadStations(completion: @escaping (_ res: Bool) -> Void) {
		let ref = Database.database().reference().child("Stations")
		ref.observeSingleEvent(of: .value, with: {snapshot in
			
			let snapValue = snapshot as! DataSnapshot
			let statDict = snapValue.value as! NSDictionary
			
			let name = statDict["nomStation"] as? String
			let nom = statDict["nomStation"] as? String
			let marque = statDict["marque"] as? String
			let adresse = statDict["adresse"] as? String
			let codepostal = statDict["codePostal"] as? String
			let ville = statDict["ville"] as? String
			let pays = statDict["pays"] as? String
			let coordGPS = statDict["coordGPS"] as? String
			let commentaire = statDict["commentaire"] as? String
			let idStation = statDict["idStation"] as? String
			let latitude = statDict["latitude"] as? String
			let longitude = statDict["longitude"] as? String
				
			let stat = self.stationItem
				
				stat?.idStation = idStation!
				stat?.nomStation = nom!
				stat?.marque = marque!
				stat?.adresse = adresse!
				stat?.codePostal = codepostal!
				stat?.ville = ville!
				stat?.latitude = (latitude as! NSString).doubleValue
				stat?.longitude = (longitude as! NSString).doubleValue
				stat?.pays = pays!
				stat?.commentaire = commentaire!
				
				self.stationArray?.append(stat!)
				completion(true)
		})
	}
	
	/* updates the firebase from csv file */
	func readCSV(completion: @escaping (_ res: Bool) -> Void){
		//CWProgressHUD.show(withMessage: "Envoi des stations")
		
		let stringPath = Bundle.main.path(forResource: "stations-03052019-short-adresses-nettoyees", ofType: "csv")
		let urlPath = Bundle.main.url(forResource: "stations-03052019-short-adresses-nettoyees", withExtension: "csv")
		
		let fileStream = InputStream(fileAtPath: stringPath!)
		/*let csv = try! CSVReader(stream: stream)
		while let row = csv.next() {
			print("\(row)")
		}*/
		
		let csvString = "id;idStation;nomStation;marque;latitude;longitude;creadtedAt;modifiedAt;adresse;codePostal;ville;pays;heureDebut;heureFin;commentaire;Gazole_prix;Gazole_maj;Gazole_user;DieselPlus_prix;DieselPlus_maj;DieselPlus_user;SP95 E10_prix;SP95 E10_maj;SP95 E10_user;SP95_prix;SP95_maj;SP95_user;SP98_prix;SP98_maj;SP98_user;EssencePlus_prix;EssencePlus_maj;EssencePlus_user;services;compteur;valid"
		
		var cpt = 0
		var fullrow:String?
		let csv = try! CSVReader(stream: fileStream!, hasHeaderRow: true)
		let headerRow = csv.headerRow!
		var statutCopie:Bool = true
		
		let processGroup = DispatchGroup()
		
		while let row = csv.next() {
			
			fullrow = row.joined(separator: ",")
			let fileLine = fullrow!.components(separatedBy: ";")
			
			processGroup.enter()
			insertStation(fileLine: fileLine, completion: {
				(stationInserted) in
				if(stationInserted == true){
					
					cpt = cpt+1
					print("export" + CGFloat(Double(cpt)/Double(12759)).description + " %")
					CWProgressHUD.show(withProgress: CGFloat(Double(cpt)/Double(12759)), andMessage: "Export en cours...")
					processGroup.leave()
					
				}else{
					statutCopie = false
				}
			})
			
			if(cpt == 12759){
				
				completion(true)
			}
		}
		
		processGroup.notify(queue: .main) {
			if statutCopie {
				print("All Good")
				CWProgressHUD.dismiss()
			} else {
				print("There was an error when saving data, please try again later.")
			}
		}
	}
	
	/* updates local realm with stations info from csv */
	func updateStationsMarqueFromCSV(){
		//CWProgressHUD.show(withMessage: "Envoi des stations")
		
		let stringPath = Bundle.main.path(forResource: "stations-03052019-short-adresses-nettoyees", ofType: "csv")
		let urlPath = Bundle.main.url(forResource: "stations-03052019-short-adresses-nettoyees", withExtension: "csv")
		
		let fileStream = InputStream(fileAtPath: stringPath!)
		
		let csvString = "id;idStation;nomStation;marque;latitude;longitude;creadtedAt;modifiedAt;adresse;codePostal;ville;pays;heureDebut;heureFin;commentaire;Gazole_prix;Gazole_maj;Gazole_user;DieselPlus_prix;DieselPlus_maj;DieselPlus_user;SP95 E10_prix;SP95 E10_maj;SP95 E10_user;SP95_prix;SP95_maj;SP95_user;SP98_prix;SP98_maj;SP98_user;EssencePlus_prix;EssencePlus_maj;EssencePlus_user;services;compteur;valid"
		
		var cpt = 0
		var fullrow:String?
		let csv = try! CSVReader(stream: fileStream!, hasHeaderRow: true)
		let headerRow = csv.headerRow!
		var statutCopie:Bool = true
		
		while let row = csv.next() {
			
			fullrow = row.joined(separator: ",")
			let fileLine = fullrow!.components(separatedBy: ";")
			//
			let stationId = fileLine[0]
			let stationMarque = fileLine[3]
			let stationName = fileLine[2]
			
			let realm = try! Realm()
			
			try! realm.write {
				
				let itemStation = realm.objects(stationsBDD.self).filter("idStation = %@",stationId).first
				
				if(itemStation != nil){
					itemStation?.marque = stationMarque
					itemStation?.nomStation = stationName
					
					/*if (UIImage(named: stationMarque.uppercased()) != nil) {
						print("Image station existing")
						itemStation!.data = UIImage(named: stationMarque.uppercased())!.jpegData(compressionQuality: 0.9) as NSData?
					}
					else {
						itemStation!.data = UIImage(named: "icon_fuels")!.jpegData(compressionQuality: 0.9) as NSData?
					}*/
					
					realm.add(itemStation!, update: .modified)
				}
				
			}
		}
	}
	
	func insertStation(fileLine: Array<String>, completion: @escaping (_ stationInserted: Bool) -> Void){
		
		let id = fileLine[0]
		
		let idStation = fileLine[1];
		let nomStation = fileLine[2];
		let marque = fileLine[3];
		
		let latitude = fileLine[4];
		let longitude = fileLine[5];
		
		let createdAt = fileLine[6];
		let modifiedAt = fileLine[7];
		
		let adresse = fileLine[8];
		let codePostal = fileLine[9];
		let ville = fileLine[10];
		let pays = fileLine[11];
		
		let heureDebut = fileLine[12];
		let heureFin = fileLine[13];
		let commentaire = fileLine[14];
		
		let Gazole_prix = fileLine[15];
		let Gazole_maj = fileLine[16];
		let Gazole_user = fileLine[17];
		
		let DieselPlus_prix = fileLine[18];
		let DieselPlus_maj = fileLine[19];
		let DieselPlus_user = fileLine[20];
		
		let SP95E10_prix = fileLine[21];
		let SP95E10_maj = fileLine[22];
		let SP95E10_user = fileLine[23];
		
		let SP95_prix = fileLine[24];
		let SP95_maj = fileLine[25];
		let SP95_user = fileLine[26];
		
		let SP98_prix = fileLine[27];
		let SP98_maj = fileLine[28];
		let SP98_user = fileLine[29];
		
		let EssPlus_prix = fileLine[30];
		let EssPlus_maj = fileLine[31];
		let EssPlus_user = fileLine[32];
		
		let services = fileLine[33];
		let compteur = fileLine[34];
		let valid = fileLine[35];
		
		let dbRef = Database.database().reference().child("Stations").child("Fr").child(codePostal)
		let stationsDictionary : NSDictionary =
			[
				"id" : id,
				"idStation" : idStation,
				"nomStation" : nomStation,
				"marque" : marque,
				"latitude" : latitude,
				"longitude" : longitude,
				"createdAt" : getTimestamp(),
				"modifiedAt" : getTimestamp(),
				"adresse" : adresse,
				"ville" : ville,
				"codePostal" : codePostal,
				"pays" : pays,
				"commentaire" : commentaire,
				"Gazole_prix" : Gazole_prix,
				"Gazole_maj" : Gazole_maj,
				"Gazole_user" : Gazole_user,
				"DieselPlus_prix" : DieselPlus_prix,
				"DieselPlus_maj" : DieselPlus_maj,
				"DieselPlus_user" : DieselPlus_user,
				"SP95E10_prix" : SP95E10_prix,
				"SP95E10_maj" : SP95E10_maj,
				"SP95E10_user" : SP95E10_user,
				"SP95_prix" : SP95_prix,
				"SP95_maj" : SP95_maj,
				"SP95_user" : SP95_user,
				"SP98_prix" : SP98_prix,
				"SP98_maj" : SP98_maj,
				"SP98_user" : SP98_user,
				"EssencePlus_prix" : EssPlus_prix,
				"EssencePlus_maj" : EssPlus_maj,
				"EssencePlus_user" : EssPlus_user,
				"services" : services,
				"compteur" : compteur,
				"valid" : "1"
		]
		
		dbRef.child(id).setValue(stationsDictionary){
			(error, ref) in
			if error != nil {
				print(error!)
				completion(false)
			}
			else {
				//print("Progress..." + CGFloat(cpt/12759).description + " %")
				//CWProgressHUD.show(withProgress: CGFloat(cpt/1568), andMessage: "Export en cours...")
				completion(true)
			}
		}
	}
	
	func getTimestamp() -> String {
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
		return timestamp
	}
    
    func updateStationsPrice(){
        
    }
	
	// 1
	func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
		
		Utility.getUserInformation()
		
		if elementName == "pdv" {
			idStation = String()
			stationAdresse = String()
			stationCP = String()
			stationVille = String()
			stationName = String()
			marque = String()
			latitude = 0
			longitude = 0
			services = [String]()
			horaires = [Jour]()
			carburants = [Carburant]()
			self.jourObj = Jour()
			
			self.idStation = "Station-" + attributeDict["id"]!
			
			let realm = try! Realm()
			let realmObj = realm.objects(stationsBDD.self).filter("idStation = %@",self.idStation).first
			
			if(realmObj != nil){
				self.marque = (realmObj?.marque.uppercased())!
			}else{
				self.marque = "STATION SERVICE"
			}
			
			
			if((attributeDict["latitude"] != nil)&&(attributeDict["latitude"] != "")){
				self.latitude =  Double(attributeDict["latitude"]!)!/100000
			}else{
				self.latitude =  0
			}
			if((attributeDict["longitude"] != nil)&&(attributeDict["longitude"] != "")){
				self.longitude =  Double(attributeDict["longitude"]!)!/100000
			}else{
				self.longitude =  0
			}
			if(attributeDict["cp"] != nil){
				self.stationCP = attributeDict["cp"]!
			}else{
				self.stationCP =  "0"
			}
		}
		
		if ((elementName == "prix")&&(attributeDict["nom"] != nil)){
			let date = attributeDict["maj"]!
			let carburant = attributeDict["nom"]!
			let prixBrut = attributeDict["valeur"]!
				
			let carbu = Carburant(nomCarburant: carburant, userPseudo: "Francis", dateMaj: Utility.getUTCTimestamp(), prix: Double(prixBrut)!/1000, rupture: false)
			self.carburants.append(carbu)
		}
		
		if (elementName == "jour"){
			self.jourObj?.jour = attributeDict["nom"]!
			let ferme = attributeDict["ferme"]!
			//let jour =
		}
		if (elementName == "horaire"){
			let ouverture = attributeDict["ouverture"]!
			let fermeture = attributeDict["fermeture"]!
			self.jourObj?.ouverture = ouverture
			self.jourObj?.fermeture = fermeture
			self.jourObj?.dateMaj = Utility.getUTCTimestamp()
			self.jourObj?.userPseudo = Utility.userPseudo!
			self.horaires.append(self.jourObj!)
		}
		
		self.elementName = elementName
	}
	
	// 2
	func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == "pdv" {
			let stationItem = StationItem(idStation: idStation, stationName: stationName, stationAdresse: stationAdresse, stationCP: stationCP, stationVille: stationVille, marque: marque, latitude: latitude, longitude: longitude, services: services, horaires: horaires, carburants: carburants)
			stations.append(stationItem)
		}
	}
	
	// 3
	func parser(_ parser: XMLParser, foundCharacters string: String) {
		let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
		let str = Utility.replaceSpecialCharsFromString(text: data)

		if (!data.isEmpty) {
			if self.elementName == "adresse" {
				var correctedArray = [String]()
				let strArray = str.split(separator: " ")
				for strArr in strArray {
					correctedArray.append(strArr.firstUppercased)
					//strArr.firstUppercased
				}
				stationAdresse += correctedArray.joined(separator: " ")
			}
			if self.elementName == "cp" {
				stationCP = str
			}
			if self.elementName == "ville" {
				let majStr = str.uppercased()
				stationVille = majStr
				stationName = self.marque.firstCapitalized + " - " + stationVille.firstCapitalized
			}
			if self.elementName == "latitude" {
				latitude += Double(data) as! Double/10000.00
			}
			if self.elementName == "longitude" {
				longitude += Double(data) as! Double/10000.00
			}
			if self.elementName == "service" {
				//print(str)
				services.append(str)
			}
			if self.elementName == "horaire" {
				print(str)
				//horaires.append(str)
			}
		}
	}
	
	/* Imports stations from bundled xml file on input to realm */
	func importStationsFromXML(){
		if let path = Bundle.main.url(forResource: "PrixCarburants_quotidien_20190810", withExtension: "xml") {
			if let parser = XMLParser(contentsOf: path) {
				parser.delegate = self
				parser.parse()
			}
		}
		self.index = 0
		let realm = try! Realm()
		try! realm.write {
			for station in self.stations
			{
				self.index += 1
				CWProgressHUD.show()
				let stat = stationsBDD()
				stat.idStation = station.idStation
				stat.adresse = station.stationAdresse
				stat.latitude = station.latitude
				stat.longitude = station.longitude
				stat.codePostal = station.stationCP
				stat.ville = station.stationVille
				stat.pays = "France"
				
				
				for service in station.services{
					stat.services.append(service)
				}
				realm.add(stat)
				print(CGFloat(100 * self.index/self.stations.count).description + " %")
			}
		}
		CWProgressHUD.dismiss()
		
		let alertView = SCLAlertView() //Replace the IconImage text with the image name
		alertView.showSuccess("Import terminé", subTitle: "L'import est terminé !")
	}
	
	/* Imports stations from bundled xml file on input to realm */
	func updateFirebaseDataFromXML(){
		if let path = Bundle.main.url(forResource: "PrixCarburants_quotidien_20190810", withExtension: "xml") {
			if let parser = XMLParser(contentsOf: path) {
				parser.delegate = self
				parser.parse()
			}
		}
		self.index = 0
		let realm = try! Realm()
		try! realm.write {
			for station in self.stations
			{
				self.index += 1
				CWProgressHUD.show()
				let stat = stationsBDD()
				stat.idStation = station.idStation
				stat.adresse = station.stationAdresse
				stat.latitude = station.latitude
				stat.longitude = station.longitude
				stat.codePostal = station.stationCP
				stat.ville = station.stationVille
				stat.pays = "France"
				
				
				for service in station.services{
					stat.services.append(service)
				}
				realm.add(stat)
				print(CGFloat(100 * self.index/self.stations.count).description + " %")
			}
		}
		CWProgressHUD.dismiss()
		
		let alertView = SCLAlertView() //Replace the IconImage text with the image name
		alertView.showSuccess("Import terminé", subTitle: "L'import est terminé !")
	}
	
	/* Creates Firebase database from bundled xml file */
	func updateFirebasePriceFromXML(){
		if let path = Bundle.main.url(forResource: "PrixCarburants_quotidien_20191102", withExtension: "xml") {
			if let parser = XMLParser(contentsOf: path) {
				parser.delegate = self
				parser.parse()
			}
		}
		self.index = 0
		let group = DispatchGroup()
		group.enter()
		for stationObj in self.stations{
			group.enter()
			
			updateFirebaseObject(station: stationObj) {
				(stationInserted) in
				if stationInserted == true{
					print("stationId = %@ insérée")
					group.leave()
				}
			}
		}
		group.leave()
		
		let alertView = SCLAlertView() //Replace the IconImage text with the image name
		alertView.showSuccess("Import terminé", subTitle: "L'import est terminé !")
	}
	
	/* Creates Firebase database from bundled xml file */
	func updatePricesFromXML(){
//		let ProgressWait = SCLAlertView()
//		ProgressWait.showWait("Patientez svp", subTitle: "Chargement des stations")
		
		if let path = Bundle.main.url(forResource: "PrixCarburants_quotidien_20191102", withExtension: "xml") {
			if let parser = XMLParser(contentsOf: path) {
				parser.delegate = self
				parser.parse()
			}
		}
		var i:Int=0
//		let ProgressWait2 = SCLAlertView()
//		ProgressWait2.showWait("Patientez svp", subTitle: "Mise à jour des prix")
		for stationObj in self.stations{
			i += 1
			CWProgressHUD.show(withProgress: CGFloat(i/self.stations.count), andMessage: "Export en cours...")
			print(stationObj.idStation)
			// update GPS coordinates
			let refGPS = Database.database().reference().child("Stations").child("Fr").child(stationObj.stationCP)
			let updateLatitude = ["latitude": stationObj.latitude]
			let updateLongitude = ["longitude": stationObj.longitude]
			
			refGPS.child(stationObj.idStation).updateChildValues(updateLatitude, withCompletionBlock: {
				(error:Error?, refGPS) -> Void in
				print("updateLatitude error",error)

			})
			refGPS.child(stationObj.idStation).updateChildValues(updateLongitude, withCompletionBlock: {
				(error:Error?, refGPS) -> Void in
				print("updateLongitude error",error)

			})
			
			// update prices
			for carburant in stationObj.carburants {
				let maj = carburant.nomCarburant + "_maj"
				let prix = carburant.nomCarburant + "_prix"
				let user = carburant.nomCarburant + "_user"
				let rupture = carburant.nomCarburant + "_rupture"
				print(carburant.nomCarburant,carburant.prix)
				let ref = Database.database().reference().child("Stations").child("Fr").child(stationObj.stationCP)
				
				let updateDateMaj = [maj: carburant.dateMaj]
				let updatePrix = [prix: carburant.prix]
				let updatePseudo = [user: carburant.userPseudo]
				
				ref.child(stationObj.idStation).updateChildValues(updateDateMaj, withCompletionBlock: {
					(error:Error?, ref) -> Void in
					print("updateDateMaj error",error)

				})
				ref.child(stationObj.idStation).updateChildValues(updatePrix, withCompletionBlock: {
					(error:Error?, ref) -> Void in
					print("updatePrix error",error)

				})
				ref.child(stationObj.idStation).updateChildValues(updatePseudo, withCompletionBlock: {
					(error:Error?, ref) -> Void in
					print("updatePseudo error",error)
					
				})
			}
		}
//		self.index = 0
//		let stationInserted = true
//		while(stationInserted == true){
//			if(self.index < self.stations.count - 1){
//
//				/*updateStationsPrice(station: stationObj) {
//					(stationInserted) in
//					if stationInserted == true{
//						print("code postal = %@",stationObj.stationCP)
//						self.index+=1
//					}
//				}*/
//			}else{
//				let stationInserted = false
//			}
//		}
		let alertView = SCLAlertView() //Replace the IconImage text with the image name
		alertView.showSuccess("Import terminé", subTitle: "L'import est terminé !")
	}
	
	func updateStationsPrice(station: StationItem, completion: @escaping (_ stationInserted: Bool) -> Void){
		let ref = Database.database().reference().child("Stations").child("Fr").child(station.stationCP).child(station.idStation)
		for carburant in station.carburants {
			let maj = [carburant.nomCarburant + "_maj" : carburant.dateMaj]
			let prix = [carburant.nomCarburant + "_prix" : carburant.prix.description]
			let user = [carburant.nomCarburant + "_user" : carburant.userPseudo]
			let rupture = [carburant.nomCarburant + "_rupture" : "Non"]
			
			ref.updateChildValues(maj, withCompletionBlock:{
				error, ref in
				if error != nil{
					print("ERROR")
				}
				else{
					ref.updateChildValues(prix, withCompletionBlock: {error, ref in
						if error != nil{
							print("ERROR")
						}
						else{
							ref.updateChildValues(user, withCompletionBlock: {error, ref in
								if error != nil{
									print("ERROR")
								}
								else{
									ref.updateChildValues(rupture, withCompletionBlock: {error, ref in
										if error != nil{
											print("ERROR")
										}
									})
								}
							})
						}
					})
				}
			})
		}
		let servicesString = station.services.joined(separator: ";")
		ref.updateChildValues(["services" : servicesString], withCompletionBlock: {error, ref in
			if error != nil{
				print("ERROR")
			}
			else{
				CWProgressHUD.show(withProgress: CGFloat(100*Double(self.index)/Double(self.stations.count)), andMessage: "Import en cours")
				print(station.idStation)
				completion(true)
			}
		})
	}
	
	func updateFirebaseObject(station: StationItem, completion: @escaping (_ stationInserted: Bool) -> Void){
		let ref = Database.database().reference().child("Stations").child("Fr").child(station.stationCP)
		
		let stationsDict : NSDictionary =
			[
				"idStation" : station.idStation,
				"nomStation" : station.stationName,
				"marque" : station.marque,
				"adresse" : station.stationAdresse,
				"ville" : station.stationVille,
				"codePostal" : station.stationCP,
				"pays" : "Fr",
				"latitude" : station.latitude.description,
				"longitude" : station.longitude.description,
				"commentaire" : "",
				"modifiedAt" : Utility.getUTCTimestamp(),
				"createdAt" : Utility.getUTCTimestamp(),
				"verif" : 1,
				"Gazole_maj" : 0.00,
				"Gazole_prix" : 0.00,
				"Gazole_user" : 0.00,
				"Gazole_rupture" : 0.00,
				"DieselPlus_maj" : 0.00,
				"DieselPlus_prix" : 0.00,
				"DieselPlus_user" : 0.00,
				"DieselPlus_rupture" : 0.00,
				"SP95_maj" : 0.00,
				"SP95_prix" : 0.00,
				"SP95_user" : 0.00,
				"SP95_rupture" : 0.00,
				"SP98_maj" : 0.00,
				"SP98_prix" : 0.00,
				"SP98_user" : 0.00,
				"SP98_rupture" : 0.00,
				"EssencePlus_maj" : 0.00,
				"EssencePlus_prix" : 0.00,
				"EssencePlus_user" : 0.00,
				"EssencePlus_rupture" : 0.00,
				"E10_maj" : 0.00,
				"E10_prix" : 0.00,
				"E10_user" : 0.00,
				"E10_rupture" : 0.00,
				"E85_maj" : 0.00,
				"E85_prix" : 0.00,
				"E85_user" : 0.00,
				"E85_rupture" : 0.00,
				"GPLc_maj" : 0.00,
				"GPLc_prix" : 0.00,
				"GPLc_user" : 0.00,
				"GPLc_rupture" : 0.00,
				"services" : ""
		]
		let servicesString = station.services.joined(separator: ";")
		ref.child(station.idStation).setValue(stationsDict){
			(error, ref) in
			if error != nil {
				print(error!)
				completion(false)
			}
			else {
				//print("Progress..." + CGFloat(cpt/12759).description + " %")
				//CWProgressHUD.show(withProgress: CGFloat(cpt/1568), andMessage: "Export en cours...")
				var carbDict = [String : String]()
				for carburant in station.carburants {
					ref.updateChildValues([carburant.nomCarburant + "_maj" : carburant.dateMaj])
					ref.updateChildValues([carburant.nomCarburant + "_prix" : carburant.prix.description])
					ref.updateChildValues([carburant.nomCarburant + "_user" : carburant.userPseudo])
					ref.updateChildValues([carburant.nomCarburant + "_rupture" : "Non"])
				}
				
				ref.updateChildValues(["services" : servicesString]){
					(error, ref) in
					self.index+=1
					CWProgressHUD.show(withProgress: CGFloat(100*Double(self.index)/Double(self.stations.count)), andMessage: "Import en cours")
					completion(true)
				}
			}
		}
	}
}

	
	


/*extension UIViewController: XMLParserDelegate {
	
	// initialize results structure
	
	public func parserDidStartDocument(_ parser: XMLParser) {
		Result = []
	}
	
	// start element
	//
	// - If we're starting a "record" create the dictionary that will hold the results
	// - If we're starting one of our dictionary keys, initialize `currentValue` (otherwise leave `nil`)
	
	public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		if elementName == recordKey {
			currentDictionary = [:]
		} else if dictionaryKeys.contains(elementName) {
			currentValue = ""
		}
	}
	
	// found characters
	//
	// - If this is an element we care about, append those characters.
	// - If `currentValue` still `nil`, then do nothing.
	
	public func parser(_ parser: XMLParser, foundCharacters string: String) {
		currentValue? += string
	}
	
	// end element
	//
	// - If we're at the end of the whole dictionary, then save that dictionary in our array
	// - If we're at the end of an element that belongs in the dictionary, then save that value in the dictionary
	
	public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		if elementName == recordKey {
			results!.append(currentDictionary!)
			currentDictionary = nil
		} else if dictionaryKeys.contains(elementName) {
			currentDictionary![elementName] = currentValue
			currentValue = nil
		}
	}
	
	// Just in case, if there's an error, report it. (We don't want to fly blind here.)
	
	public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
		print(parseError)
		
		currentValue = nil
		currentDictionary = nil
		results = nil
	}
	
}*/
