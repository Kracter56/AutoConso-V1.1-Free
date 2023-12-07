//
//  AddConsoEurekaViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 06/05/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import Eureka
import RealmSwift
import Firebase
import FirebaseDatabase

class AddStationEurekaViewController: FormViewController {
	
	var realm:Realm?
	var listOfCars:[Car] = []
	var station:Station?
	var listOfTypesCarburants:[String]?
	
	let listOfStationServices:[String] = ["AGIP", "ANTAR", "AUCHAN", "AVIA", "BP", "CARREFOUR", "DYNEFF", "E.LECLERC", "ELF", "ESSO EXPRESS", "ESSO", "EXXON", "FINA", "IRVING", "SHELL", "TOTAL ACCESS", "TOTAL", "U"]
	//let listOfTypesCarburants:[String] = ["ESSENCE PLUS (Haut de gamme)", "SUPER", "SANS PLOMB 98", "SANS PLOMB 95", "SANS PLOMB 95 E10", "DIESEL PLUS (Haut de gamme)", "GAZOLE", "ETHANOL", "FlexFuel", "GPL"]
	let listOfTypesCarburantsEN:[String] = ["ESSENCE PLUS (Haut de gamme)", "SUPER", "SANS PLOMB 98", "SANS PLOMB 95", "SANS PLOMB 95 E10", "DIESEL PLUS (Haut de gamme)", "GAZOLE", "ETHANOL", "FlexFuel", "GPL"]
	let listOfServices:[String] = ["Station de gonflage", "Vente de gaz domestique (Butane, Propane)", "Carburant additivé", "Toilettes publiques", "DAB (Distributeur automatique de billets)", "Laverie", "Restauration à emporter", "Restauration sur place", "Location de véhicule", "Boutique alimentaire", "Piste poids lourds", "Boutique non alimentaire", "Bar", "Services réparation / entretien", "Relais colis", "Douches", "Aire de camping-cars", "Lavage manuel", "Vente de fioul domestique", "Lavage automatique", "Bornes électriques", "Automate CB 24/24", "GNV", "Vente de pétrole lampant", "Espace bébé", "Wifi", "Vente d'additifs carburants"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let StationSectionTitle = NSLocalizedString("Nom de la station", comment: "StationSectionTitle")
		let StationSectionFooter = NSLocalizedString("Choisissez le nom de la station", comment: "StationSectionFooter")
		let StationAddressTitle = NSLocalizedString("Saisir l'adresse de la station", comment: "StationAddressTitle")
		let StationAddressFooter = NSLocalizedString("Localisation de la station", comment: "StationAddressTitle")
		let StationCarburantTypesTitle = NSLocalizedString("Liste de carburants", comment: "StationCarbTitle")
		let StationCarburantTypesFooter = NSLocalizedString("Choisir les différents carburants", comment: "StationCarbFooter")
		let ServicesListTitle = NSLocalizedString("Services", comment: "ServicesListTitle")
		let ServicesListFooter = NSLocalizedString("Choisir les services proposés par la station", comment: "ServicesListFooter")
		
		getCarburantsList()
		
		form
		+++ Section(StationSectionTitle)
			<<< PushRow<String>() {
				$0.title = "Marque de la station"
				$0.selectorTitle = "Sélectionner une station"
				$0.options = self.listOfStationServices
				$0.value = "TOTAL"    // initially selected
				$0.add(rule: RuleRequired())
				$0.tag = "marque"
				$0.validationOptions = .validatesOnChange
			}
			.cellUpdate { cell, row in
				if !row.isValid {
					cell.textLabel?.textColor = .red
				}
			}
			
		+++ Section(StationAddressTitle)
			<<< TextRow() { // 3
				$0.title = "Adresse" //4
				$0.placeholder = "Saisir l'adresse"
				$0.onChange { [unowned self] row in //6
					//self.viewModel.title = row.value
				}
				$0.add(rule: RuleRequired())
				$0.tag = "adresse"
				$0.validationOptions = .validatesOnChange
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			
			<<< ZipCodeRow() { // 3
				$0.title = "Code Postal" //4
				$0.placeholder = "Saisir le code postal"
				$0.onChange { [unowned self] row in //6
					//self.viewModel.title = row.value
				}
				$0.add(rule: RuleMaxLength(maxLength: 5))
				$0.tag = "codePostal"
				$0.validationOptions = .validatesOnChange
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			
			<<< TextRow() { // 3
				$0.title = "Ville" //4
				$0.placeholder = "Saisir la ville"
				$0.onChange { [unowned self] row in //6
					//self.viewModel.title = row.value
				}
				$0.add(rule: RuleRequired())
				$0.tag = "ville"
				$0.validationOptions = .validatesOnChange
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			
		+++ Section(StationCarburantTypesTitle)
			<<< MultipleSelectorRow<String>() {
				$0.title = "Carburants"
				$0.tag = "carburantsList"
				$0.selectorTitle = "Sélectionner les carburants disponibles"
				$0.options = self.listOfTypesCarburants
				//$0.value = "GAZOLE"    // initially selected
			}
			
		+++ Section(ServicesListTitle)
			<<< MultipleSelectorRow<String>() {
				$0.title = "Services"
				$0.tag = "servicesList"
				$0.selectorTitle = "Sélectionner les services de la station"
				$0.options = self.listOfServices
		}
		
		+++ Section()
			<<< ButtonRow(){
				$0.title = "Valider"
				$0.validate()
				}.onCellSelection({
					(cell, row) in
					self.station = Station()
					self.generateStationId()
					
					let formvalues = self.form.values()
					
					/* Marque de la station */
					if(formvalues["marque"] != nil){
						self.station?.marque = formvalues["marque"] as! String
					}
					if(formvalues["adresse"] != nil){
						self.station?.adresse = formvalues["adresse"] as! String
					}
					if(formvalues["codePostal"] != nil){
						self.station?.codePostal = formvalues["codePostal"] as! String
					}
					if(formvalues["ville"] != nil){
						self.station?.ville = formvalues["ville"] as! String
					}
					if let services = formvalues["servicesList"] as? Set<String> {
						let servicesString = services.joined(separator: "-")
						print(servicesString)
						self.station?.services = servicesString
					}
					
					if let carburants = formvalues["carburantsList"] as? Set<String> {
						print(carburants)
						/*for carburant in carburants{
							switch carburant{
							case "Superethanol E85":
								
							case "GNC - Gaz Naturel Comprimé":
								
							case "Diesel":
								
							case "Diesel Excellium":
								
							case "Essence Sans Plomb 95":
								
							case "Essence Sans Plomb 98":
								
							case "Essence Sans Plomb 95 E10":
								
							case "GPL-c":
								
							case "Hydrogène":
								
							case "Diesel Premier":
								
							case "LNG - Gaz Naturel Liquéfié":
								
							case "Supreme+ Sans Plomb 98":
								
							case "Supreme+ Gazole":
								
							case "Essence BP Ultimate SP98":
								
							case "Essence BP Ultimate SP95":
								
							case "Diesel BP Ultimate":
							}
						}*/
						
					}
					
					
					self.createStation(station: self.station!, completion: {
						(statut) in
						if (statut == 1){
							print("Station insérée")
							self.toastMessage("La station a bien été créée")
							self.navigationController?.popViewController(animated: true)
						}
					})
					
				})
	}
	
	func getCarsList(){
		let realm = try! Realm()
		self.listOfCars = Array(realm.objects(Car.self))
	}
	
	func getCarburantsList(){
		self.listOfTypesCarburants = []
		let realm = try! Realm()
		let list = Array(realm.objects(typeCarburant.self))
		for item in list{
			self.listOfTypesCarburants?.append(item.NomCarburant)
		}
		self.listOfTypesCarburants?.sort()
	}
	
	func generateStationId(){
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.dateFormat = "ddMMYYYYHHmmss"
		self.station!.idStation = "Station-" + dateFormatter.string(from: Date())
	}
	
	func createStation(station: Station, completion: @escaping (Int)-> Void){
		print("Entrée dans createStation")
		let userID = UserDefaults.standard.string(forKey: "usrPseudo")
		createStationId()
		print(self.station)
		let tableStation = Database.database().reference().child("Stations").child("Fr").child((self.station!.codePostal).description)
		let stationsDisctionary : NSDictionary =
			[
				"id" : self.station!.idStation,
				"idStation" : self.station!.idStation,
				"nomStation" : self.station!.marque + " " + self.station!.ville,
				"marque" : self.station!.marque,
				"latitude" : self.station!.latitude.description,
				"longitude" : self.station!.longitude.description,
				"typeRoute" : self.station!.typeRoute,
				"adresse" : self.station!.adresse,
				"ville" : self.station!.ville,
				"codePostal" : self.station!.codePostal.description,
				"pays" : self.station!.pays,
				"heureDebut" : "-",
				"heureFin" : "-",
				"commentaire" : "",
				"saufJour" : "-",
				"services" : self.station!.services,
				"modifiedAt" : getTimestamp(),
				"createdAt" : getTimestamp(),
				"compteur" : 0,
				"verif" : 0,
				"DieselPlus_maj" : getUTCTimestamp(),
				"DieselPlus_prix" : 0.00,
				"DieselPlus_user" : userID,
				"DieselPlus_rupture" : "Non",
				"EssencePlus_maj" : getUTCTimestamp(),
				"EssencePlus_prix" : 0.00,
				"EssencePlus_user" : userID,
				"EssencePlus_rupture" : "Non",
				"SuperEthanolE85_maj" : getUTCTimestamp(),
				"SuperEthanolE85_prix" : 0.00,
				"SuperEthanolE85_user" : userID,
				"SuperEthanolE85_rupture" : "Non",
				"GNC_maj" : getUTCTimestamp(),
				"GNC_prix" : 0.00,
				"GNC_user" : userID,
				"GNC_rupture" : "Non",
				"GNL_maj" : getUTCTimestamp(),
				"GNL_prix" : 0.00,
				"GNL_user" : userID,
				"GNL_rupture" : "Non",
				"SP95E10_maj" : getUTCTimestamp(),
				"SP95E10_prix" : 0.00,
				"SP95E10_user" : userID,
				"SP95E10_rupture" : "Non",
				"SP95_maj" : getUTCTimestamp(),
				"SP95_prix" : 0.00,
				"SP95_user" : userID,
				"SP95_rupture" : "Non",
				"Gazole_maj" : getUTCTimestamp(),
				"Gazole_prix" : 0.00,
				"Gazole_user" : userID,
				"Gazole_rupture" : "Non",
				"SP98_maj" : getUTCTimestamp(),
				"SP98_prix" : 0.00,
				"SP98_user" : userID,
				"SP98_rupture" : "Non",
				"GPLc_maj" : getUTCTimestamp(),
				"GPLc_prix" : 0.00,
				"GPLc_user" : userID,
				"GPLc_rupture" : "Non"
		]
		
		tableStation.child(self.station!.idStation).setValue(stationsDisctionary) {
			(error, ref) in
			if error != nil {
				print(error!)
				completion(0)
			}
			else {
				print("Station insérée!")
				print("stationId = %@",ref.key)
				completion(1)
			}
		}
	}
	
	func getUTCTimestamp() -> String {
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
	
	func getTimestamp() -> String {
		let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
		return timestamp
	}
	
	/* Fonction qui crée l'id de la conso */
	func createStationId() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.dateFormat = "ddMMYYYYHHmmss"
		self.station!.idStation = "Station-" + dateFormatter.string(from: Date())
	}
}
extension AddStationEurekaViewController{

	class ViewModel {
		
		/*private var toDos: [ToDo]
		private lazy var dateFormatter: DateFormatter = {
			let fmtr = DateFormatter()
			fmtr.dateFormat = "EEEE, MMM d"
			return fmtr
		}()
		
		var numberOfToDos: Int {
			return toDos.count
		}
		
		private func toDo(at index: Int) -> ToDo {
			return toDos[index]
		}
		
		func title(at index: Int) -> String {
			return toDo(at: index).title ?? ""
		}
		
		func dueDateText(at index: Int) -> String {
			let date = toDo(at: index).dueDate
			return dateFormatter.string(from: date)
		}
		
		func editViewModel(at index: Int) -> EditToDoItemViewController.ViewModel {
			let toDo = self.toDo(at: index)
			let editViewModel = EditToDoItemViewController.ViewModel(toDo: toDo)
			return editViewModel
		}
		
		func addViewModel() -> EditToDoItemViewController.ViewModel {
			let toDo = ToDo()
			toDos.append(toDo)
			let addViewModel = EditToDoItemViewController.ViewModel(toDo: toDo)
			return addViewModel
		}
		
		@objc private func removeToDo(_ notification: Notification) {
			guard let userInfo = notification.userInfo,
				let toDo = userInfo[Notification.Name.deleteToDoNotification] as? ToDo,
				let index = toDos.index(of: toDo) else {
					return
			}
			toDos.remove(at: index)
		}
		
		// MARK: Life Cycle
		init(toDos: [ToDo] = []) {
			self.toDos = toDos
			
			NotificationCenter.default.addObserver(self, selector: #selector(removeToDo(_:)), name: .deleteToDoNotification, object: nil)
		}
		
		deinit {
			NotificationCenter.default.removeObserver(self)
		}*/
	}
}
