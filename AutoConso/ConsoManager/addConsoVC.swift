//
//  editConsoViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 20/10/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import ImageRow
import CWProgressHUD
import CoreLocation
import SCLAlertView
import Firebase
import FirebaseDatabase

class addConsoVC: FormViewController, CLLocationManagerDelegate {

	var listOfVehicles:[String] = []
	var consoItem: Conso!
	var station: Station!
	var car: Car!
	var bLocalize:Bool?
	var coordGPS = CLLocation()
	var myLatitude:CLLocationDegrees?
	var myLongitude:CLLocationDegrees?
	var currentAddress:String?
	var currentCity:String?
	var currentPostalCode:String?
	var idConso:String?
	var carLastKm:Int = 0
	var carDateAchat:Date?
	var compteurVal:Int = 0
	var listeMarques:[String]=[]
	var listeCarburantsEssenceFR:[String]=[]
	var listeCarburantsDieselFR:[String]=[]
	var listeCarburantsEssenceEN:[String]=[]
	var listeCarburantsDieselEN:[String]=[]
	var iModeRecherche:Int=0
	var fpc:UITableViewController?
	var source:String?
	var usrCountry:String?
	
	let listOfTypesCarburantsEN:[String] = ["Diesel", "Ethanol", "Gasoline", "Hydrogen", "LPG", "Methanol", "Nitromethane", "Electric", "FlexFuel", "GPL"]
	let listOfTypesCarburantsEssenceFR:[String] = ["E85", "SP95", "SP95E10", "Essence +"]
	let listOfTypesCarburantsDieselFR:[String] = ["Diesel", "Diesel Excellium", "Diesel Premier", "Supreme+ Gazole", "Diesel BP Ultimate"]
	let listOfTypesCarburantsAutresFR:[String] = ["Essence", "SUPER", "SANS PLOMB 98", "SANS PLOMB 95", "SANS PLOMB 95 E10", "DIESEL PLUS (Haut de gamme)", "GAZOLE", "ETHANOL", "FlexFuel", "GPL"]
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		self.modalPresentationStyle = .formSheet
		self.title = textStrings.createTicket
		self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(checkData)), animated: true)
		self.usrCountry = UserDefaults.standard.string(forKey: "usrCountry")
		self.consoItem = Conso()
//		self.station = Station()
		
		
		//createStationId()
		if(self.car == nil){
			let realm = try! Realm()
			self.car = realm.objects(Car.self).first
		}
		
		self.carLastKm = Utility.getLastCarKM(car: self.car)
		self.carDateAchat = Utility.getCarDateAchat(car: self.car)
		
		listerStations()
		listerCarburants()
		
		buildForm(toForm: form)
		
//		let stationMarqueRow = self.form.rowBy(tag: "marqueStation") as! TextRow
//		stationMarqueRow.value = self.station.marque
//		stationMarqueRow.reload()
//
//		let stationAddressRow = self.form.rowBy(tag: "adresseStation") as! TextRow
//		stationAddressRow.value = self.station.adresse
//		stationAddressRow.reload()
//
//		let stationCPRow = self.form.rowBy(tag: "CPStation") as! IntRow
//		stationCPRow.value = self.station.codePostal
//		stationCPRow.reload()
//
//		let stationCityRow = self.form.rowBy(tag: "villeStation") as! TextRow
//		stationCityRow.value = self.station.ville
//		stationCityRow.reload()
		
		
	}
	
	private func buildForm(toForm form: Form){
		
		/* Section : Véhicules */
		let vehicleSection = Section(textStrings.vehicle)//, footer: textStrings.strChoisirVehicule)
		let vehicles = LabelRow("vehicule"){
			$0.title = textStrings.vehicle
			if(self.car != nil){
				$0.value = self.car.pseudo
			}else{
				$0.value = ""
			}
		}
		vehicleSection.append(vehicles)
		
		let strMake = NSLocalizedString("Marque", comment: "strMake")
		
		/* Section : Station Service */
		let stationSection = Section(textStrings.strStationService)
		let stationNameField = PushRow<String>("marqueStation"){
			$0.title = strMake
			if(self.station != nil){
				$0.value = self.station.marque
			}else{
				$0.value = ""
			}
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
			$0.options = self.listeMarques
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
				let marque = row.value
				self.consoItem.station?.marque = marque!
			}
		}
		stationSection.append(stationNameField)
		
		let stationAddressField = TextRow("adresseStation"){
			$0.title = textStrings.strAdresse
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
			if(self.station != nil){
				$0.value = self.station.adresse
			}else{
				$0.value = ""
			}
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}
		stationSection.append(stationAddressField)
		
		let stationCP = TextRow("CPStation"){
			$0.title = textStrings.strCodePostal
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
			if(self.station != nil){
				$0.value = self.station.codePostal
			}else{
				$0.value = "75000"
			}
		}
		stationSection.append(stationCP)
		
		let stationVilleField = TextRow("villeStation"){
			$0.title = textStrings.strVille
			if(self.station != nil){
				$0.value = self.station.ville
			}else{
				$0.value = ""
			}
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}
		stationSection.append(stationVilleField)
		
		if(self.source != "map"){
			let buttonMeLocaliser = ButtonRow(){
				(row: ButtonRow) in
				row.title = textStrings.strAlreadyOnStation
				row.cell.backgroundColor = .green
				row.cell.tintColor = .white
			}.onCellSelection({ (cell, row) in
				
				CWProgressHUD.show()
				
				Utility.getCurrentCoordinates(completion: {
					(statut) in
					if (statut == 1){
						self.coordGPS = Utility.currentCoordinates
						
						/* Once coordinates are obtained, display on the form */
						self.myLatitude = self.coordGPS.coordinate.latitude
						self.myLongitude = self.coordGPS.coordinate.longitude
						print("myLatitude = " + self.myLatitude!.description)
						print("myLongitude = " + self.myLongitude!.description)
						self.bLocalize = true
					}
				})
				
				/* Convert coordinates to address using Utility class */
				Utility.getAdressFromLocation(loc: self.coordGPS, completion: {
					(numero, adresse, codePostal, ville) in
					
					self.currentAddress = numero + ", " + adresse
					self.currentPostalCode = codePostal
					self.currentCity = ville
				})
				
				
				let stationAddressRow = self.form.rowBy(tag: "adresseStation") as! TextRow
				stationAddressRow.value = self.currentAddress
				stationAddressRow.reload()
				
				let stationCPRow = self.form.rowBy(tag: "CPStation") as! TextRow
				stationCPRow.value = self.currentPostalCode
				stationCPRow.reload()
				
				let stationCityRow = self.form.rowBy(tag: "villeStation") as! TextRow
				stationCityRow.value = self.currentCity
				stationCityRow.reload()
				
				CWProgressHUD.dismiss()
			})
			stationSection.append(buttonMeLocaliser)
			
			let buttonStationsSearch = ButtonRow(textStrings.strChercherStation){
				(row: ButtonRow) in
				row.title = row.tag
				row.cell.backgroundColor = .blue
				row.cell.tintColor = .white
			}
			.onCellSelection({ (cell, row) in
				
				if(self.bLocalize == false){
					Utility.getCurrentCoordinates(completion: {
						(statut) in
						if (statut == 1){
							self.coordGPS = Utility.currentCoordinates
							
							/* Once coordinates are obtained, display on the form */
							self.myLatitude = self.coordGPS.coordinate.latitude
							self.myLongitude = self.coordGPS.coordinate.longitude
							print("myLatitude = " + self.myLatitude!.description)
							print("myLongitude = " + self.myLongitude!.description)
						}
					})
				}
				
				/* Convert coordinates to address using Utility class */
				Utility.getAdressFromLocation(loc: self.coordGPS, completion: {
					(numero, adresse, codePostal, ville) in
					
					self.currentAddress = numero + ", " + adresse
					self.currentPostalCode = codePostal
					self.currentCity = ville
					
					var addressString = self.currentAddress
					addressString! += self.currentPostalCode!.description
					addressString! += self.currentCity!
					
					let stationNameRow = form.rowBy(tag: "marqueStation") as! PushRow<String>
					let marqueStation = stationNameRow.value as! String
					
					let storyboard = UIStoryboard(name: "Main", bundle: nil)
					let vc = storyboard.instantiateViewController(withIdentifier: "stationsSearchList") as! stationsTableViewController
					
					var adresseComplete:String = numero
					adresseComplete += " "
					adresseComplete += adresse
					adresseComplete += ", "
					adresseComplete += codePostal
					adresseComplete += " "
					adresseComplete += ville
					
					/* Envoi de la recherche */
					vc.senderVC = "AddConsoVC"
					vc.addConsoVC = self
					vc.searchedStation = marqueStation
					vc.stationName = marqueStation //self.consoItem.station?.nomStation
					vc.searchedAddress = adresseComplete
					vc.searchedVille = ville
					vc.searchedCP = codePostal
					vc.carName = self.car.pseudo
					vc.oConso = self.consoItem
					vc.latitudeDistance = 2000
					vc.longitudeDistance = 2000
					vc.currentAddress = addressString
					
					self.navigationController?.pushViewController(vc, animated: true)
				})
			})
			stationSection.append(buttonStationsSearch)
		}
		/* Section : Informations sur le ticket */
		let ravitaillementSection = Section(textStrings.detailsTicket)
		
		let dateRow = DateRow("dateTicket"){
			$0.title = "Date"
			$0.value = Date()
			$0.dateFormatter?.dateFormat = "dd/MM/yyyy"
		}.onChange() {
			row in
			var dataConso:Date
			
			let dateConso = row.value
			let dateAchat = self.carDateAchat as! Date
			
			if (dateConso! < dateAchat) {
				let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
				let popup = SCLAlertView(appearance: appearance)
				popup.addButton("OK", backgroundColor: UIColor.gray, textColor: UIColor.white){
				}
				popup.showWarning(textStrings.strErreur, subTitle: textStrings.strDateKMError)
			}else{
				self.consoItem.dateConso = row.value!
			}
		}
		ravitaillementSection.append(dateRow)
		
		let typeParcours = ActionSheetRow<String>("typeParcours"){
			$0.title = textStrings.typeCycle
			$0.value = "Mixte"
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
			$0.options = [textStrings.cycleUrbain, textStrings.cycleMixte, textStrings.cycleRoutier]
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}
		ravitaillementSection.append(typeParcours)
		
		let kilometrageVehicule = IntRow("carKilometrage"){
			$0.title = textStrings.strKilometrage
			$0.placeholder = textStrings.strType
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesAlways
			$0.value = self.carLastKm
		}.onChange() {
			row in
			if(row.value != nil){
				let kmActuel = row.value as! Int
				let ecartKM = kmActuel - self.carLastKm as! Int
				let kmRow = self.form.rowBy(tag: "kmParcourus") as! DecimalRow
				kmRow.value = Double(ecartKM)
				kmRow.reload()
			}
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}
		ravitaillementSection.append(kilometrageVehicule)
		
		let kmParcourus = DecimalRow("kmParcourus"){
			$0.title = textStrings.strKMParcourus
			$0.placeholder = textStrings.strType
			$0.value = Double(self.carLastKm)
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
		}.cellUpdate { cell, row in
			
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
        }.onChange { row in
			let km = row.value as! Double
			let volRow = form.rowBy(tag: "nbLitres") as! DecimalRow
			let consoRow = self.form.rowBy(tag: "conso") as! DecimalRow
			let conso = (volRow.value!/km)*100
			consoRow.value = conso
			consoRow.reload()
		}
		ravitaillementSection.append(kmParcourus)
		
		let switchPlein = SwitchRow("switchPlein"){
			row in
			row.title = textStrings.strPlein
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}.onChange { row in
			let plein = row.value
			if plein == true {
				self.consoItem.statusPlein = true
				//print("plein = " + plein!.description)
			}else{
				self.consoItem.statusPlein = false
				//print("plein = " + plein!.description)
			}
		}
		ravitaillementSection.append(switchPlein)
		
		let typeCarburant = ActionSheetRow<String>("typeCarburant"){
			$0.title = "Carburant"
			$0.value = ""
			$0.add(rule: RuleRequired())
			if(self.usrCountry == "France"){
				if(Utility.getCarEnergie(car: self.car) == "Essence"){
					$0.options = self.listeCarburantsEssenceFR
				}
				if(Utility.getCarEnergie(car: self.car) == "Diesel"){
					$0.options = self.listeCarburantsDieselFR
				}
			}else{
				$0.options = self.listOfTypesCarburantsEN
			}
			$0.validationOptions = .validatesOnChange
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}.onChange { row in
			let typeCarb = row.value
			self.consoItem.typeCarburant = typeCarb!
		}
		ravitaillementSection.append(typeCarburant)
		
		let litres = DecimalRow("nbLitres"){
			$0.title = textStrings.nbLitres
			$0.value = 0.00
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}.onChange { row in
			if(row.value != nil){
				let vol = row.value as! Double
				let kmRow = form.rowBy(tag: "kmParcourus") as! DecimalRow
				let consoRow = self.form.rowBy(tag: "conso") as! DecimalRow
				let conso = (vol/kmRow.value!)*100
				consoRow.value = conso
				consoRow.reload()
			}
		}
		ravitaillementSection.append(litres)
		
		let prix = DecimalRow("prix"){
			$0.title = textStrings.strPrix
			$0.value = 0.00
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
		}.cellUpdate { cell, row in
			
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
        }.onChange { row in
			if(row.value != nil){
				let prix = row.value as! Double
				let litresRow = form.rowBy(tag: "nbLitres") as! DecimalRow
				let litres = Double(litresRow.value!)
				
				let coutLitre = prix/litres
				
				let coutLitreRow = self.form.rowBy(tag: "coutlitres") as! DecimalRow
				coutLitreRow.value = coutLitre
				coutLitreRow.reload()
			}
		}
		ravitaillementSection.append(prix)
		
		let coutlitres = DecimalRow("coutlitres"){
			$0.title = textStrings.coutLitre
			$0.value = 0.00
		}
		ravitaillementSection.append(coutlitres)
		
		let conso = DecimalRow("conso"){
			$0.title = textStrings.strConso
		}
		ravitaillementSection.append(conso)
		
		
		let image = ImageRow("photoTicket") { row in
			row.title = "Ticket"
			row.value = UIImage(named: "icon_fuels")
			row.sourceTypes = [.All]
			row.clearAction = .yes(style: UIAlertAction.Style.destructive)
		}.onChange() { row in
			let image = NSData(data: (row.value?.pngData())!)
			self.consoItem.data = image
		}
		
		/* Section : Notes */
		let mesNotesSection = Section(textStrings.strMesNotes)
		let commentaire = TextAreaRow("Commentaire"){
			$0.title = "Mes Notes"
			$0.value = ""
			$0.placeholder = textStrings.strCommentaire
		}.onChange() { row in
			let commentaire = row.value
			self.consoItem.commentaire = commentaire!
		}
		mesNotesSection.append(commentaire)
		
		let justifSection = Section(header: "Photo du ticket", footer: "Cliquer pour choisir une photo enregistrée")
		justifSection.append(image)
		
		form.append(vehicleSection)
		form.append(stationSection)
		form.append(ravitaillementSection)
		form.append(justifSection)
		form.append(mesNotesSection)
		
		if(self.source == "map"){
			let saveSection = Section()
			let saveBtn = ButtonRow("SaveBtn"){
				$0.title = textStrings.strEnregistrer
				$0.value = textStrings.strEnregistrer
			}.onCellSelection({ (cell, row) in
				self.checkData()
			})
			saveSection.append(saveBtn)
			
			let closeBtn = ButtonRow("CloseBtn"){
				$0.title = textStrings.strFermer
				$0.value = textStrings.strFermer
			}.onCellSelection({ (cell, row) in
				self.dismiss(animated: true, completion: nil)
			})
			saveSection.append(closeBtn)
			
			form.append(saveSection)
		}
	}
	
	@objc func checkData(){
		print("userCountry = %@",self.usrCountry)
		if(self.usrCountry == "France"){
			if(self.station.idStation == ""){
				/* Vérification de l'id de station
				CAS 1 - Station a proximité sans id ?
				CAS 2 - Station renseignée à la main ?
				*/
				
				validateFields()
				
				var addressArray:[String]?
				addressArray?.append(self.station.adresse + ",")
				addressArray?.append(self.station.codePostal.description)
				addressArray?.append(self.station.ville)
				let addressString = addressArray?.joined(separator: " ")
				
				if(self.station.latitude == 0.0){
				
					Utility.getCoordinatesFromAddress(address: addressString!, completion:  {
						(coordinates) in
						if(coordinates.coordinate.latitude != 0.0){
							print("coordonnées GPS OK")
							
							
							
						}else{
							let titreAdresseInvalide = NSLocalizedString("Adresse invalide", comment: "titreAdresseInvalide")
							let messageAdresseInvalide = NSLocalizedString("Vous avez saisi une adresse invalide. Veuillez vérifier et réessayez. N'hésitez pas à utiliser la fonction Recherche de station.", comment: "messageAdresseInvalide")
							SCLAlertView().showError(titreAdresseInvalide, subTitle: messageAdresseInvalide)
							
						}
					})
				}else{
					
					searchStationId(marque: self.station.marque, codePostal: self.station!.codePostal, ville: self.station.ville, searchedLatitude: self.station.latitude, searchedLongitude: self.station.longitude, completion: {
							(status) in
							if(status == 2){
								self.saveData()
								print("status =",status)
								self.navigationController?.popViewController(animated: true)
								return
							}
							if(status == 4){
								
								self.createStation(station: self.station!, completion: {
									(statutInsertion) in
									
									if(statutInsertion == 1){
										print("station insertion OK")
									}
									if(statutInsertion == 0){
										print("erreur lors de l'insertion de la station")
									}
								})
								
								self.saveData()
								print("status =",status)
								self.navigationController?.popViewController(animated: true)
								return
							}
					})
					
				}
			}else{
				
				self.saveData()
			}
		}else{
			// Si le pays n'est pas la France, enregistrer direct dans la base interne realm
			self.saveData()
			self.navigationController?.popViewController(animated: true)
		}
	}
	
	@objc func saveData(){
		let valuesDict = form.values()
		print(valuesDict)
		
		validateFields()
		
		if self.compteurVal == 0 {
		
			let realm = try! Realm()
			try! realm.write {
				print(valuesDict["adresseStation"] as! String)
				
				let marque = (valuesDict["marqueStation"] as! String).uppercased()
				let ville = valuesDict["villeStation"] as! String
				let adresse = valuesDict["adresseStation"] as! String
				let CP = valuesDict["CPStation"] as! String
				let UIimageJustif = valuesDict["photoTicket"] as! UIImage
				let imJustif = (UIimageJustif.pngData()) as! Data
				let typeCarburant = valuesDict["typeCarburant"] as! String
				let nomStation = marque
				
				var	imageStation:NSData = NSData(data: (UIImage(named: "icon_fuels")?.pngData())!)
				if let img = UIImage(named: marque) {
					imageStation = NSData(data: img.pngData()!)
				}
				
				let imageJustif = NSData(data: imJustif)
				self.consoItem.carName = self.car.pseudo
				self.consoItem.idStation = self.station.idStation
				self.consoItem.idCar = self.car.idCar
				self.consoItem.car = self.car
				self.consoItem.stationImage = imageStation
				self.consoItem.nomStation = nomStation
				self.consoItem.dateConso = valuesDict["dateTicket"] as! Date
				self.consoItem.adresseStation = adresse
				self.consoItem.CPStation = CP
				self.consoItem.typeCarburant = typeCarburant as! String
				self.consoItem.villeStation = ville
				self.consoItem.carKilometrage = valuesDict["carKilometrage"] as! Int
				self.consoItem.carKmParcourus = Float(valuesDict["kmParcourus"] as! Double)
				self.consoItem.volConso = Float(valuesDict["nbLitres"] as! Double)
				self.consoItem.typeParcours = valuesDict["typeParcours"] as! String
				self.consoItem.prix = Float(valuesDict["prix"] as! Double)
				self.consoItem.conso = Float(valuesDict["conso"] as! Double)
				self.consoItem.coutLitre = Float(valuesDict["coutlitres"] as! Double)
				self.consoItem.data = imageJustif as NSData
				
				/*self.consoItem.station!.marque = marque
				self.consoItem.station!.adresse = adresse
				self.consoItem.station!.codePostal = Int(CP)!
				self.consoItem.station!.ville = ville
				self.consoItem.station!.carburant = valuesDict["typeCarburant"] as! String
				self.consoItem.station!.consos.append(self.consoItem)
				self.consoItem.station!.coordGPS = self.coordGPS.description
				self.consoItem.station!.latitude = self.myLatitude!
				self.consoItem.station!.longitude = self.myLongitude!*/
				//self.consoItem.station
				
				//TODO: Ajouter lztitude longitude
				self.station.nomStation = self.station.marque + " " + self.station.ville
				createConsoId()
				self.consoItem.idConso = self.idConso!
				print(self.consoItem)
				print(self.station)
				realm.add(self.consoItem, update: .modified)
				realm.add(self.station, update: .modified)
			}
			
		}else{
			let appearance = SCLAlertView.SCLAppearance(showCloseButton: false)
			let popup = SCLAlertView(appearance: appearance)
			popup.addButton("OK", backgroundColor: UIColor.gray, textColor: UIColor.white){
			}
			popup.showError(textStrings.strErreur, subTitle: "Vous avez " + self.compteurVal.description + " champs mal renseignés. Veuillez revoir les champs en rouge et revalidez.")
		}
	}
	
	func validateFields(){
		let val = form.values()
		self.compteurVal = 0
		
		let ville = val["villeStation"] as! String
		if(ville == ""){
			let villeRow = self.form.rowBy(tag: "villeStation") as! TextRow
			villeRow.cell.textLabel?.textColor = .systemRed
			self.compteurVal += 1
		}
		
		let prix = val["prix"] as! Double
		if(prix == 0.0){
			let prixRow = self.form.rowBy(tag: "prix") as! DecimalRow
			prixRow.cell.textLabel?.textColor = .systemRed
			self.compteurVal += 1
		}
		
		let kmParcourus = val["kmParcourus"] as! Double
		if(kmParcourus == Double(self.carLastKm)){
			let kmParcRow = self.form.rowBy(tag: "kmParcourus") as! DecimalRow
			kmParcRow.cell.textLabel?.textColor = .systemRed
			self.compteurVal += 1
		}else{
			if(kmParcourus < 0){
				let kmParcRow = self.form.rowBy(tag: "kmParcourus") as! DecimalRow
				kmParcRow.cell.textLabel?.textColor = .systemRed
				self.compteurVal += 1
			}
		}
		
		let marqueStation = val["marqueStation"] as! String
		if(marqueStation == ""){
			let marqueStationRow = self.form.rowBy(tag: "marqueStation") as! PushRow<String>
			marqueStationRow.cell.textLabel?.textColor = .systemRed
			self.compteurVal += 1
		}
		
		let typeCarburant = val["typeCarburant"] as! String
		if(typeCarburant == nil){
			let typeCarburantRow = self.form.rowBy(tag: "typeCarburant") as! ActionSheetRow<String>
			typeCarburantRow.cell.textLabel?.textColor = .systemRed
			self.compteurVal += 1
		}
		
		let nbLitres = val["nbLitres"] as! Double
		if(nbLitres == 0.0){
			let nbLitresRow = self.form.rowBy(tag: "nbLitres") as! DecimalRow
			nbLitresRow.cell.textLabel?.textColor = .systemRed
			self.compteurVal += 1  		}else{
			if(nbLitres < 0){
				let nbLitresRow = self.form.rowBy(tag: "nbLitres") as! DecimalRow
				nbLitresRow.cell.textLabel?.textColor = .systemRed
				self.compteurVal += 1
			}
		}
		
		let carKilometrage = val["carKilometrage"] as! Int
		if(carKilometrage == self.carLastKm){
			let carKilometrageRow = self.form.rowBy(tag: "carKilometrage") as! IntRow
			carKilometrageRow.cell.textLabel?.textColor = .systemRed
			self.compteurVal += 1
		}
	}
	
	func stationSelected(data: stationObject)
	{
		print("Station received: \(String(describing: data.nom))")
		let stationNameRow = self.form.rowBy(tag: "marqueStation") as! PushRow<String>
		stationNameRow.value = data.marque
		stationNameRow.reload()
		
		let stationAdresseRow = self.form.rowBy(tag: "adresseStation") as! TextRow
		stationAdresseRow.value = data.adresse
		stationAdresseRow.reload()
		
		let stationCPRow = self.form.rowBy(tag: "CPStation") as! TextRow
		stationCPRow.value = data.codePostal
		stationCPRow.reload()
		
		let stationVilleRow = self.form.rowBy(tag: "villeStation") as! TextRow
		stationVilleRow.value = data.ville
		stationVilleRow.reload()
		
		if(self.station == nil){
			self.station = Station()
		}
		if(UIImage(named: data.marque.uppercased()) !== nil){
			let image = UIImage(named: data.marque.uppercased())?.pngData()
			self.station.data = NSData(data: image!)
		}else{
			let image = UIImage(named: "icon_fuels")?.pngData()
			self.station.data = NSData(data: image!)
		}
		
		self.station.marque = data.marque
		self.station.adresse = data.adresse
		self.station.idStation = data.idStation
		self.station.ville = data.ville
		self.station.codePostal = data.codePostal
		self.station.latitude = data.latitude
		self.station.longitude = data.longitude
		self.station.services = data.services
		
	}
	
	func getCurrentAddress()->Void{
		CWProgressHUD.show()
		/* Convert coordinates to address using Utility class */
		Utility.getAdressFromLocation(loc: self.coordGPS, completion: {
			(numero, adresse, codePostal, ville) in
			
			self.currentAddress = numero + ", " + adresse
			self.currentPostalCode = codePostal
			self.currentCity = ville
		})
		CWProgressHUD.dismiss()
	}
	
	override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)
        print("addConsoVC->ViewWillAppear")
		
		/* Avant l'affichage, récupérer la position de l'utilisateur */
		CWProgressHUD.show()
		self.bLocalize = true
		Utility.getCurrentCoordinates(completion: {
			(statut) in
			if (statut == 1){
				self.coordGPS = Utility.currentCoordinates
				
				/* Once coordinates are obtained, display on the form */
				self.myLatitude = self.coordGPS.coordinate.latitude
				self.myLongitude = self.coordGPS.coordinate.longitude
				print("myLatitude = " + self.myLatitude!.description)
				print("myLongitude = " + self.myLongitude!.description)
			}
		})
		CWProgressHUD.dismiss()
		
    }
	
	
	/* Fonction qui crée l'id de la conso */
	func createConsoId() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "ddMMYYYYHHmmss"
        self.idConso = "Conso-" + dateFormatter.string(from: Date())
    }
    
    /* Fonction qui crée l'id de la conso */
    func createStationId() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "ddMMYYYYHHmmss"
		self.station!.idStation = "Station-" + dateFormatter.string(from: Date())
    }
	
	func listerStations(){
		let realm = try! Realm()
		let stations = realm.objects(stationsBDD.self)
		
		for station in stations{
			let marque = station.marque
			if !self.listeMarques.contains(marque){
				self.listeMarques.append(marque)
			}
		}
	}
	
	func listerCarburants(){
		let realm = try! Realm()
		let carburantsEssence = realm.objects(typeCarburant.self).filter("Energie = %@","Essence")
		let carburantsDiesel = realm.objects(typeCarburant.self).filter("Energie = %@","Diesel")
		for carb in carburantsEssence{
			let carbName = carb.NomCarburant
			self.listeCarburantsEssenceFR.append(carbName)
		}
		for carb in carburantsDiesel{
			let carbName = carb.NomCarburant
			self.listeCarburantsDieselFR.append(carbName)
		}
	}
	
	func searchStationId(marque: String, codePostal: String, ville: String, searchedLatitude: Double, searchedLongitude: Double, completion: @escaping (Int)-> Void){
		let id = ""
		var statut = 0
		
		let coord = CLLocationCoordinate2D(latitude: searchedLatitude, longitude: searchedLongitude)
		
		/*Utility.checkInternetConnection(){
			(connected) in
			self.connected = connected
			if connected == true {*/
				let stationsRef = Database.database().reference().child("Stations").child("Fr").child(codePostal.description)
				stationsRef.observeSingleEvent(of: .value, with: { (snapshot) in
					print(snapshot)
					
					if(snapshot.value is NSNull){
						// NO DATA
						print("– – – Data was not found – – –")
						completion(1)
						/*self.listeStations.removeAll()*/
						SCLAlertView().showError("Recherche invalide", subTitle: "Votre recherche n'a donné aucun résultat")
						CWProgressHUD.dismiss();statut = 1
					}else{
						for stationItem in snapshot.children {
							// DATA FOUND
							
							let station_snap = stationItem as! DataSnapshot
							let idStat = station_snap.key as! String
							let dict = station_snap.value as! NSDictionary
							
							let sLatitude = dict["latitude"] as! String
							let sLongitude = dict["longitude"] as! String
							let scodePostal = dict["codePostal"] as! String
							let sVille = dict["ville"] as! String
							let sAdresse = dict["adresse"] as! String
							
							/* On remplace les , par des . pour avoir une valeur type Float */
							let latitude = sLatitude.replacingOccurrences(of: ",", with: ".")
							let longitude = sLongitude.replacingOccurrences(of: ",", with: ".")
							
							
							let dSearchedLatitude = Double(self.station!.latitude)
							let dSearchedLongitude = Double(self.station!.longitude)
							
							/* Distance calculation */
							let locationSearchedStation = CLLocation(latitude: dSearchedLatitude, longitude: dSearchedLongitude)
							let locationCurrentStation = CLLocation(latitude: (latitude as NSString).doubleValue, longitude:(longitude as NSString).doubleValue)
							
							/* Distance from the center calculation */
							let rawDistance = (locationSearchedStation.distance(from: locationCurrentStation))/1000
							let distance = String(format: "%.2f", rawDistance)
							let FlDistance = Float(distance)
							let tolerance = Float(0.05)	// Tolerance de 50m
							print("Station " + idStat + ", distance = ",distance)
							/*print("coord. station cherchée : %@",)
							print("coord. station de comparaison : %@",)*/
							if((FlDistance?.isLessThanOrEqualTo(tolerance))!) {
								print("station trouvée dans Firebase id = @%",idStat)
								self.station?.idStation = idStat
								completion(2)
								statut = 2
								CWProgressHUD.dismiss()
								return
							}else{
								print("NOK")
								completion(3)
								statut = 3
							}
						}
						if(statut == 3){
							print("station non trouvée dans Firebase")
							statut = 4
							completion(4)
						}
					}
				})
			/*}else{
				// Internet Connection NOK
			}
		}*/
	}
	
	func updatePrice(completion: @escaping (Int)->Void){
		print("Entrée dans updatePrice")
		
		let valuesDict = form.values()
		let coutLitres = valuesDict["coutlitres"] as! Double
		let status = 0
		
		let typeCarburant = self.consoItem.typeCarburant
		let userID = UserDefaults.standard.string(forKey: "usrPseudo")
		
		//calculerCoutLitre()
		//let coutL = TextFieldCoutLitre?.text //Calcul du prix au litre
		
		var prixTypeCarb = ""
		var majTypeCarb = ""
		var userTypeCarb = ""
		
		switch typeCarburant {
		case "Supreme+ Sans Plomb 98":
			prixTypeCarb = "EssencePlus_prix"
			majTypeCarb = "EssencePlus_maj"
			userTypeCarb = "EssencePlus_user"
		case "Essence BP Ultimate SP98":
			prixTypeCarb = "EssencePlus_prix"
			majTypeCarb = "EssencePlus_maj"
			userTypeCarb = "EssencePlus_user"
		case "Essence Sans Plomb 98":
			prixTypeCarb = "SP98_prix"
			majTypeCarb = "SP98_maj"
			userTypeCarb = "SP98_user"
		case "Essence Sans Plomb 95":
			prixTypeCarb = "SP95_prix"
			majTypeCarb = "SP95_maj"
			userTypeCarb = "SP95_user"
		case "Essence Sans Plomb 95 E10":
			prixTypeCarb = "E10_prix"
			majTypeCarb = "E10_maj"
			userTypeCarb = "E10_user"
		case "Diesel Excellium":
			prixTypeCarb = "DieselPlus_prix"
			majTypeCarb = "DieselPlus_maj"
			userTypeCarb = "DieselPlus_user"
		case "Supreme+ Gazole":
			prixTypeCarb = "DieselPlus_prix"
			majTypeCarb = "DieselPlus_maj"
			userTypeCarb = "DieselPlus_user"
		case "Diesel":
			prixTypeCarb = "Gazole_prix"
			majTypeCarb = "Gazole_maj"
			userTypeCarb = "Gazole_user"
		case "Diesel Premier":
			prixTypeCarb = "Gazole_prix"
			majTypeCarb = "Gazole_maj"
			userTypeCarb = "Gazole_user"
		case "Superethanol E85":
			prixTypeCarb = "Ethanol_prix"
			majTypeCarb = "Ethanol_maj"
			userTypeCarb = "Ethanol_user"
		case "FlexFuel":
			prixTypeCarb = "FlexFuel_prix"
			majTypeCarb = "FlexFuel_maj"
			userTypeCarb = "FlexFuel_user"
		case "GPL-c":
			prixTypeCarb = "GPLc_prix"
			majTypeCarb = "GPLc_maj"
			userTypeCarb = "GPLc_user"
		case "GPL-c":
			prixTypeCarb = "GNC_prix"
			majTypeCarb = "GNC_maj"
			userTypeCarb = "GNC_user"
		case "GPL-c":
			prixTypeCarb = "GNL_prix"
			majTypeCarb = "GNL_maj"
			userTypeCarb = "GNL_user"
		default:
			prixTypeCarb = "EssencePlus_prix"
			majTypeCarb = "EssencePlus_maj"
			userTypeCarb = "EssencePlus_user"
		}
		
		var formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
		
		let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description)
		ref.child(self.station!.idStation).updateChildValues([prixTypeCarb: coutLitres])
		ref.child(self.station!.idStation).updateChildValues([majTypeCarb: Utility.getUTCTimestamp()])
		ref.child(self.station!.idStation).updateChildValues([userTypeCarb: userID])
		completion(1)
		
		/*getLastMajDate(carburant: majTypeCarb, completion: {
			(lastDate) in
			if(lastDate != ""){
				
				var formatter = DateFormatter()
				formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
				
				let lastMajDate = formatter.date(from: lastDate) as! Date
				let strConsoDate = formatter.string(from: self.oConso!.dateConso)
				let consoDate = formatter.date(from: strConsoDate) as! Date
				
				print(lastDate)
				
				if(consoDate > lastMajDate){
					let ref = Database.database().reference().child("Stations").child("Fr").child((self.station?.codePostal)!.description)
					ref.child(self.station!.idStation).updateChildValues([prixTypeCarb: coutL])
					ref.child(self.station!.idStation).updateChildValues([majTypeCarb: self.getUTCTimestamp()])
					ref.child(self.station!.idStation).updateChildValues([userTypeCarb: userID])
					completion(1)
				}
			}else{
				print("lastDate not found")
			}
		})*/
		
	}
	
	func createStation(station: Station, completion: @escaping (Int)-> Void){
		print("Entrée dans createStation")
		let userID = UserDefaults.standard.string(forKey: "usrPseudo")
		createStationId()
		let tableStation = Database.database().reference().child("Stations").child("Fr").child((self.station!.codePostal).description)
		let stationsDisctionary : NSDictionary =
			[
				"id" : self.station!.idStation,
				"idStation" : self.station!.idStation,
				"nomStation" : self.station!.nomStation,
				"marque" : self.station!.marque,
				"latitude" : self.station!.latitude.description,
				"longitude" : self.station!.longitude.description,
				"adresse" : self.station!.adresse,
				"ville" : self.station!.ville,
				"codePostal" : self.station!.codePostal.description,
				"pays" : self.station!.pays,
				"commentaire" : self.station!.commentaire,
				"services" : self.station!.services,
				"modifiedAt" : Utility.getUTCTimestamp(),
				"createdAt" : Utility.getUTCTimestamp(),
				"verif" : 0,
				"DieselPlus_maj" : Utility.getUTCTimestamp(),
				"DieselPlus_prix" : 0.00,
				"DieselPlus_user" : userID,
				"DieselPlus_rupture" : "Non",
				"EssencePlus_maj" : Utility.getUTCTimestamp(),
				"EssencePlus_prix" : 0.00,
				"EssencePlus_user" : userID,
				"EssencePlus_rupture" : "Non",
				"E85_maj" : Utility.getUTCTimestamp(),
				"E85_prix" : 0.00,
				"E85_user" : userID,
				"E85_rupture" : "Non",
				"GNC_maj" : Utility.getUTCTimestamp(),
				"GNC_prix" : 0.00,
				"GNC_user" : userID,
				"GNC_rupture" : "Non",
				"GNL_maj" : Utility.getUTCTimestamp(),
				"GNL_prix" : 0.00,
				"GNL_user" : userID,
				"GNL_rupture" : "Non",
				"E10_maj" : Utility.getUTCTimestamp(),
				"E10_prix" : 0.00,
				"E10_user" : userID,
				"E10_rupture" : "Non",
				"SP95_maj" : Utility.getUTCTimestamp(),
				"SP95_prix" : 0.00,
				"SP95_user" : userID,
				"SP95_rupture" : "Non",
				"Gazole_maj" : Utility.getUTCTimestamp(),
				"Gazole_prix" : 0.00,
				"Gazole_user" : userID,
				"Gazole_rupture" : "Non",
				"SP98_maj" : Utility.getUTCTimestamp(),
				"SP98_prix" : 0.00,
				"SP98_user" : userID,
				"SP98_rupture" : "Non",
				"GPLc_maj" : Utility.getUTCTimestamp(),
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
				self.updatePrice(
					completion: {
						(status) in
						if(status == 1){
							print("price updated")
						}
				})
			}
		}
	}
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
