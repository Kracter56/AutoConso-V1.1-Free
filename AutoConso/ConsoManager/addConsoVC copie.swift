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
	var currentPostalCode:Int?
	var idConso:String?
	var carLastKm:Int = 0
	var carDateAchat:Date?
	var compteurVal:Int = 0
	var listeMarques:[String]=[]
	var listeCarburantsEssenceFR:[String]=[]
	var listeCarburantsDieselFR:[String]=[]
	var listeCarburantsEssenceEN:[String]=[]
	var listeCarburantsDieselEN:[String]=[]
	
	let listOfTypesCarburantsEN:[String] = ["ESSENCE PLUS (Haut de gamme)", "SUPER", "SANS PLOMB 98", "SANS PLOMB 95", "SANS PLOMB 95 E10", "DIESEL PLUS (Haut de gamme)", "GAZOLE", "ETHANOL", "FlexFuel", "GPL"]
	let listOfTypesCarburantsEssenceFR:[String] = ["E85", "SP95", "SP95E10", "Essence +"]
	let listOfTypesCarburantsDieselFR:[String] = ["Diesel", "Diesel Excellium", "Diesel Premier", "Supreme+ Gazole", "Diesel BP Ultimate"]
	let listOfTypesCarburantsAutresFR:[String] = ["Essence", "SUPER", "SANS PLOMB 98", "SANS PLOMB 95", "SANS PLOMB 95 E10", "DIESEL PLUS (Haut de gamme)", "GAZOLE", "ETHANOL", "FlexFuel", "GPL"]
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = textStrings.createTicket
		self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveData)), animated: true)
		
		self.consoItem = Conso()
		self.station = Station()
		
		createConsoId()
		createStationId()
		
		self.carLastKm = Utility.getLastCarKM(car: self.car)
		self.carDateAchat = Utility.getCarDateAchat(car: self.car)
		self.consoItem.idConso = self.idConso!
		
		listerStations()
		listerCarburants()
		
		buildForm(toForm: form)
	}
	
	private func buildForm(toForm form: Form){
		
		/* Section : Véhicules */
		let vehicleSection = Section(textStrings.vehicle)//, footer: textStrings.strChoisirVehicule)
		let vehicles = LabelRow("vehicule"){
			$0.title = textStrings.vehicle
			$0.value = self.car.pseudo
		}
		vehicleSection.append(vehicles)
		
		/* Section : Station Service */
		let stationSection = Section(textStrings.strStationService)
		let stationNameField = PushRow<String>("marqueStation"){
			$0.title = "Marque"
			$0.value = ""
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
			$0.value = ""
		}.cellUpdate { cell, row in
			if !row.isValid {
				cell.textLabel?.textColor = .systemRed
			}else{
				cell.textLabel?.textColor = .none
			}
		}
		stationSection.append(stationAddressField)
		
		let stationCP = IntRow("CPStation"){
			$0.title = textStrings.strCodePostal
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
			$0.value = 75000
		}
		stationSection.append(stationCP)
		
		let stationVilleField = TextRow("villeStation"){
			$0.title = textStrings.strVille
			$0.value = ""
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
		
		let buttonMeLocaliser = ButtonRow(){
			(row: ButtonRow) in
			row.title = textStrings.strAlreadyOnStation
			row.cell.backgroundColor = .green
			row.cell.tintColor = .white
		}.onCellSelection({ (cell, row) in
			
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
			
			/* Convert coordinates to address using Utility class */
			Utility.getAdressFromLocation(loc: self.coordGPS, completion: {
				(numero, adresse, codePostal, ville) in
				
				self.currentAddress = numero + ", " + adresse
				self.currentPostalCode = Int(codePostal)!
				self.currentCity = ville
			})
			
			
			let stationAddressRow = self.form.rowBy(tag: "adresseStation") as! TextRow
			stationAddressRow.value = self.currentAddress
			stationAddressRow.reload()
			
			let stationCPRow = self.form.rowBy(tag: "CPStation") as! IntRow
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
				self.currentPostalCode = Int(codePostal)!
				self.currentCity = ville
				
				var addressString = self.currentAddress
				addressString! += self.currentPostalCode!.description
				addressString! += self.currentCity!
				
				let storyboard = UIStoryboard(name: "Main", bundle: nil)
				let vc = storyboard.instantiateViewController(withIdentifier: "stationsSearchList") as! stationsTableViewController
				
				/* Envoi de la recherche */
				vc.senderVC = "AddConsoVC"
				vc.addConsoVC = self
				vc.stationName = self.consoItem.station?.nomStation
				vc.searchedAddress = self.currentAddress
				vc.searchedVille = self.currentCity
				vc.searchedCP = self.currentPostalCode?.description
				vc.carName = self.car.pseudo
				vc.oConso = self.consoItem
				vc.latitudeDistance = 2000
				vc.longitudeDistance = 2000
				vc.currentAddress = addressString
				
				self.navigationController?.pushViewController(vc, animated: true)
			})
		})
		stationSection.append(buttonStationsSearch)
			
		
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
		
		let typeCarburant = PushRow<String>("typeCarburant"){
			$0.title = "Carburant"
			$0.value = ""
			if(Utility.getCarEnergie(car: self.car) == "Essence"){
				$0.options = self.listeCarburantsEssenceFR
			}
			if(Utility.getCarEnergie(car: self.car) == "Diesel"){
				$0.options = self.listeCarburantsDieselFR
			}
			$0.add(rule: RuleRequired())
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
				let CP = (valuesDict["CPStation"] as! Int).description
				let UIimageJustif = valuesDict["photoTicket"] as! UIImage
				let imJustif = (UIimageJustif.pngData()) as! Data
				
				let nomStation = marque
					
				let imageStation = NSData(data: (UIImage(named: marque)?.pngData())!)
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
				
				print(self.consoItem)
				print(self.station)
				realm.add(self.consoItem)
				realm.add(self.station, update: true)
			}
			print(self.consoItem.carKilometrage)
			self.navigationController?.popViewController(animated: true)
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
			let typeCarburantRow = self.form.rowBy(tag: "typeCarburant") as! PushRow<String>
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
		
		let stationCPRow = self.form.rowBy(tag: "CPStation") as! IntRow
		stationCPRow.value = Int(data.codePostal)
		stationCPRow.reload()
		
		let stationVilleRow = self.form.rowBy(tag: "villeStation") as! TextRow
		stationVilleRow.value = data.ville
		stationVilleRow.reload()
		
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
		self.station.codePostal = Int(data.codePostal)!
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
			self.currentPostalCode = Int(codePostal)!
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
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
