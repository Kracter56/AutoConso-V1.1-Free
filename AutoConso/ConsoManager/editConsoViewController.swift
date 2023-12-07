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
import QuickLook


class editConsoViewController: FormViewController, QLPreviewControllerDataSource {

	var listOfVehicles:[String] = []
	var consoItem: Conso!
	var listeMarques:[String]=[]
	var listeCarburantsEssenceFR:[String]=[]
	var listeCarburantsDieselFR:[String]=[]
	var listeCarburantsEssenceEN:[String]=[]
	var listeCarburantsDieselEN:[String]=[]
	var chosenCarburant:String?
	var imagedata:NSData?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		self.title = "Edition d'un ticket"
		self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveData)),animated: true)
		
		listerVehicules()
		listerStations()
		listerCarburants()
		
		buildForm(toForm: form)
	}
	
	func clearForm(ofForm form: Form){
		let nbSections = self.form.allSections.count
		for section in self.form.allSections{
			let sectionTag = section.header?.title
			if(sectionTag != "Type de périodicité"){
				self.form.remove(at: section.index!)
			}
		}
	}
	
	
	
	
	func listerVehicules(){
		let realm = try! Realm()
		let cars = realm.objects(Car.self)
		for car in cars {
			self.listOfVehicles.append(car.pseudo)
		}
	}
	
	private func buildForm(toForm form: Form){
		
		/* Section : Véhicules */
		let vehicleSection = Section(textStrings.vehicle)//, footer: textStrings.strChoisirVehicule)
		let vehicles = PushRow<String>("vehicule"){
			$0.title = textStrings.vehicle
			$0.value = self.consoItem.car?.pseudo
			$0.options = self.listOfVehicles
			$0.isDisabled
		}
		vehicleSection.append(vehicles)
		
		/* Section : Station Service */
		let stationSection = Section(textStrings.strStationService)
		let stationNameField = PushRow<String>("marqueStation"){
			$0.title = "Marque"
			$0.value = self.consoItem.nomStation
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
			$0.value = self.consoItem.adresseStation
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
			$0.value = Int(self.consoItem.CPStation)
		}
		stationSection.append(stationCP)
		
		let stationVilleField = TextRow("villeStation"){
			$0.title = textStrings.strVille
			$0.value = self.consoItem.villeStation
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
		
		let buttonStationsSearch = ButtonRow(textStrings.strChercherStation){
			(row: ButtonRow) in
			row.title = row.tag
		}.onCellSelection({ (cell, row) in
			//self.performSegueWithIdentifier("AccesoryViewControllerSegue", sender: self)
			let storyboard = UIStoryboard(name: "Main", bundle: nil)
			let vc = storyboard.instantiateViewController(withIdentifier: "stationsSearchList") as! stationsTableViewController
			
			/* Envoi de la recherche */
			vc.senderVC = "editConsoVC"
			vc.editConsoVC = self
			vc.stationName = self.consoItem.nomStation
			vc.searchedAddress = self.consoItem.adresseStation
			vc.searchedVille = self.consoItem.villeStation
			vc.searchedCP = self.consoItem.CPStation
			vc.carName = self.consoItem.car?.pseudo
			vc.oConso = self.consoItem
			vc.latitudeDistance = 2000
			vc.longitudeDistance = 2000
			vc.currentAddress = self.consoItem.adresseStation
			
			self.navigationController?.pushViewController(vc, animated: true)
		})
		stationSection.append(buttonStationsSearch)
			
		
		/* Section : Informations sur le ticket */
			let ravitaillementSection = Section(textStrings.detailsTicket)
			
			let dateRow = DateRow("dateTicket"){
				$0.title = "Date"
				$0.value = self.consoItem.dateConso
				$0.dateFormatter?.dateFormat = "dd/MM/yyyy"
			}/*.onChange() {
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
			}*/
			ravitaillementSection.append(dateRow)
			
			let typeParcours = ActionSheetRow<String>("typeParcours"){
				$0.title = textStrings.typeCycle
				$0.value = self.consoItem.typeParcours
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
				$0.value = self.consoItem.carKilometrage
			}/*.onChange() {
				row in
				if(row.value != nil){
					let kmActuel = row.value as! Int
					let ecartKM = kmActuel - self.carLastKm as! Int
					let kmRow = self.form.rowBy(tag: "kmParcourus") as! DecimalRow
					kmRow.value = Double(ecartKM)
					kmRow.reload()
				}
			}*/.cellUpdate { cell, row in
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
				$0.value = Double(self.consoItem.carKmParcourus)
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
				$0.value = self.consoItem.typeCarburant
				if(Utility.getCarEnergie(car: self.consoItem.car!) == "Essence"){
					$0.options = self.listeCarburantsEssenceFR
				}
				if(Utility.getCarEnergie(car: self.consoItem.car!) == "Diesel"){
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
				self.chosenCarburant = typeCarb!
			}
			ravitaillementSection.append(typeCarburant)
			
			let litres = DecimalRow("nbLitres"){
				$0.title = textStrings.nbLitres
				$0.value = Double(self.consoItem.volConso)
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
				$0.value = Double(self.consoItem.prix)
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
				$0.value = Double(self.consoItem.coutLitre)
			}
			ravitaillementSection.append(coutlitres)
			
			let conso = DecimalRow("conso"){
				$0.title = textStrings.strConso
				$0.value = Double(self.consoItem.conso)
			}
			ravitaillementSection.append(conso)
			
			
			let image = ImageRow("photoTicket") { row in
				row.title = "Ticket"
				if self.consoItem!.data == nil {
					row.value = UIImage(named: "icon_fuels")
				}else{
					row.value = UIImage(data: self.consoItem!.data as! Data)
				}
				
				row.sourceTypes = [.All]
				row.clearAction = .yes(style: UIAlertAction.Style.destructive)
			}.onChange() { row in
				let image = NSData(data: (row.value?.pngData())!)
				self.imagedata = image
			}
		
			let buttonVoirJustif = ButtonRow(textStrings.strVoirJustif){
				(row: ButtonRow) in
				row.title = row.tag
			}.onCellSelection({ (cell, row) in
				let previewController = QLPreviewController()
				previewController.dataSource = self
				self.present(previewController, animated: true, completion: nil)
			})
			
			
			/* Section : Notes */
			let mesNotesSection = Section(textStrings.strMesNotes)
			let commentaire = TextAreaRow("Commentaire"){
				$0.title = "Mes Notes"
				$0.value = self.consoItem.commentaire
				$0.placeholder = textStrings.strCommentaire
			}.onChange() { row in
				let commentaire = row.value
				self.consoItem.commentaire = commentaire!
			}
			mesNotesSection.append(commentaire)
			
			let justifSection = Section(header: "Photo du ticket", footer: "Cliquer pour choisir une photo enregistrée")
			justifSection.append(image)
			//justifSection.append(buttonVoirJustif)
			
			form.append(vehicleSection)
			form.append(stationSection)
			form.append(ravitaillementSection)
			form.append(justifSection)
			form.append(mesNotesSection)
		}
	
	func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
		guard let url = Bundle.main.url(forResource: String(index), withExtension: "pdf") else {
			fatalError("Could not load \(index).pdf")
		}

		return url as QLPreviewItem
	}
	
	func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
		return 1
	}
	
	@objc func saveData(){
		let valuesDict = form.values()
		print(valuesDict)
		
		let realm = try! Realm()
		try! realm.write {
			print(valuesDict["adresseStation"] as! String)
				
			let marque = (valuesDict["marqueStation"] as! String).uppercased()
			let ville = valuesDict["villeStation"] as! String
			let adresse = valuesDict["adresseStation"] as! String
			let CP = (valuesDict["CPStation"] as! Int).description
				
			let nomStation = marque
				
			var	imageStation:NSData = NSData(data: (UIImage(named: "icon_fuels")?.pngData())!)
			if let img = UIImage(named: marque) {
				imageStation = NSData(data: img.pngData()!)
			}
			self.consoItem.typeCarburant = valuesDict["typeCarburant"] as! String
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
			self.consoItem.station?.marque = marque
			self.consoItem.station?.adresse = adresse
			self.consoItem.station?.codePostal = CP
			self.consoItem.station?.ville = ville
			self.consoItem.station?.marque = marque
			self.consoItem.data = self.imagedata
			//TODO: Ajouter lztitude longitude
				
			realm.add(self.consoItem, update: .modified)
		}
		print(self.consoItem.carKilometrage)
		self.navigationController?.popViewController(animated: true)
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
