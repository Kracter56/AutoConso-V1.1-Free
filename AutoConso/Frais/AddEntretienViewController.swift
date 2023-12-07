//
//  addMaintenanceViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 14/06/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import CoreLocation
import Foundation
import CWProgressHUD
import SCLAlertView
import EventKit
import SCLAlertView

class AddEntretienViewController: FormViewController {

	var nsDictionary: NSDictionary?
	var realm:Realm?
	var entretienItemsList:[String]?
	var listOfCars:[Car] = []
	var userLocationSet:Bool?
	var oFacture:Facture?
	var oOperation:operation?
	var operationsList:[operation] = []
	var listOperations:[String] = []
	var listeEntretien:[String] = []
	var listeKM:[Int] = []
	var idFacture:String?
	var nomFacture:String?
	var idOperation:String?
	var idx:Int = 0
	var car:Car?
	var langue:String?
	var statusValidation:Bool?
	var validationList:[String] = []
	var prochaineDate:Date?
	var prochainKM:Int?
	var listTypeOperations:Results<typeOperation>!
	var listTypeOperationsToSave:[typeOperation] = []
	var ArraytypeOperations:[typeOperation] = []
	
	//let listeEntretien = ["Vidange huile moteur", "Vidange boite de vitesse manuelle", "Vidange boite de vitesse automatique", "Mise à niveau liquide lave glace", "Mise à niveau liquide de refroidissement", "Vidange liquide de frein", "Remplacement filtre à huile", "Remplacement filtre à air", "Remplacement filtre à carburant", "Remplacement filtre habitacle", "Diagnostic Batterie", "Remplacement de batterie", "Remplacement plaquettes de frein AV", "Remplacement plaquettes de frein AR", "Remplacement disques de frein AV", "Remplacement disque de frein AR","Remplacement pneus AV", "Remplacement pneus AR", "Parallélisme AV", "Parallélisme AR", "Contrôle de géométrie"]
	
	let listeReparation = ["Courroie de distribution", "etc"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.statusValidation = true
		self.validationList = []
		// Enables the navigation accessory and stops navigation when a disabled row is encountered
		navigationOptions = RowNavigationOptions.Enabled.union(.StopDisabledRow)
		// Enables smooth scrolling on navigation to off-screen rows
		animateScroll = true
		// Leaves 20pt of space between the keyboard and the highlighted row after scrolling to an off screen row
		rowKeyboardSpacing = 20
		
		self.langue = UserDefaults.standard.string(forKey: "phoneLanguage")!
		createFactureName()
		
		if let path = Bundle.main.path(forResource: "MaintenanceList", ofType: "plist") {
			nsDictionary = NSDictionary(contentsOfFile: path)
		}
		
		/* Listes statiques */
		let listOfServices:[String] = ["Entretien courant"]
		
		let section = ["Huiles et liquides", "Filtres", "Batterie", "Système de Freinage", "Pneus"]
		
		let listTypeInter:[String] = ["Entretien", "Réparation"]
		
		/* Construction de la liste de véhicules */
		let realm = try! Realm()
		let listOfCar = List<String>()
		
		listerTypeOperations()
		
		/*
		liste des champs:
		- Type d'intervention
		- Categorie : ex: huiles et liquides
		- Opération : Vidange moteur, 
		
		
		*/
		
		self.listOfCars = Array(realm.objects(Car.self))
		
		form
			
			+++ Section("Informations facture")
			/*<<< DateInlineRow(){
				$0.title = "Date de la facture"
				$0.value = Date(timeIntervalSinceNow: 0)
				$0.tag = "dateFacture"
				$0.add(rule: RuleRequired())
				$0.validationOptions = .validatesOnChange
			}*/
			<<< DateInlineRow() { row in
				row.tag = "dateFacture"
				}.cellSetup { cell, row in
					row.title = "Date"
					cell.textLabel?.text = ""
				}.cellUpdate { cell , row in
					if let date = row.value {
						let formatDate = DateFormatter()
						formatDate.dateFormat = "dd/MM/yyyy"
						/*formatDate.dateStyle = .short
						formatDate.timeStyle = .none
						formatDate.locale = Locale(identifier: "FR.fr")
						let dateStr = formatDate.string(from: Date())*/
						cell.detailTextLabel?.text = formatDate.string(from: date)
						cell.textLabel?.text = "Date"//row.dateFormatter?.string(from: date)
					}
					/*cell.textLabel?.textColor = row.title == "Date" ? .gray : .black
					cell.detailTextLabel?.text = ""*/
			}
			/*.cellSetup({ (dateCell, dateTimeRow) in
				})*//*.onChange({ (row) in
					/*if let value = row.value {
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "yyyy-MM-dd"
						let date = dateFormatter.string(from: value)
						
						/*let item = CustomField(coulmnId: fieldId, columnValue: date)
						self.addToCustom(set: item)*/
					}*/
					let formatDate = DateFormatter()
					formatDate.dateStyle = .medium
					formatDate.timeStyle = .none
					formatDate.locale = Locale(identifier: "FR.fr")
					let dateStr = formatDate.string(from: Date())
					row.value = formatDate.date(from: dateStr)
					//dateCell.row.value = formatDate.date(from: dateStr)
				})*/
			<<< TextRow(){
				$0.title = "Nom"
				$0.placeholder = self.nomFacture    // initially selected
				$0.tag = "nomFacture"
				$0.add(rule: RuleRequired())
				$0.validationOptions = .validatesOnChange
				}.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			<<< TextRow(){
				$0.title = "Réf. Facture"
				$0.placeholder = "Saisir"    // initially selected
				$0.tag = "refFacture"
			}
			
			
			
			<<< DecimalRow(){ row in
				row.title = "Prix total"
				row.placeholder = "Saisir le montant de la facture en euros"
				row.tag = "montantFacture"
				}.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			<<< PushRow<String>() {
				$0.title = "Type d'intervention"
				$0.selectorTitle = "type"
				$0.options = listTypeInter
				$0.value = "Entretien"    // initially selected
				$0.tag = "typeIntervention"
				}.cellUpdate{ cell, row in
					var type = cell.detailTextLabel?.text
					
					if(type == "Entretien"){
						self.listOperations = self.listeEntretien
					}
					
					if(type == "Reparation"){
						self.listOperations = self.listeReparation
					}
					
			}
			
			+++
			MultivaluedSection(multivaluedOptions: [.Insert, .Delete, .Reorder],
				header: "Liste des Operations",
				footer: "Saisissez une opération d'entretien par ligne") {
				$0.tag = "MVSectionOperations"
				$0.multivaluedRowToInsertAt = { index in
					PushRow<String> {
						$0.title = "Opération"
						$0.selectorTitle = "Appuyez pour sélectionner"
						$0.options = self.listOperations
					}
				}
			}
			<<< SwitchRow("switchStatus"){
				$0.title = "Comptabiliser dans les statistiques"
			}
			+++ Section("Informations véhicule")
			<<< TextRow() {
				$0.title = "Véhicule"
				$0.value = car?.pseudo // initially selected
				$0.tag = "pseudoVeh"
				$0.disabled = true
				$0.add(rule: RuleRequired())
				$0.validationOptions = .validatesOnChange
			}
			<<< IntRow(){
				$0.title = "Kilométrage"
				$0.value = self.car?.kilometrage    // initially selected
				$0.tag = "kilometrageVehicule"
				$0.add(rule: RuleRequired())
				$0.validationOptions = .validatesOnChange
				}.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			+++ Section(header: "Prochaine échéance", footer: "Me rappeler à la prochaine échéance")
			<<< SwitchRow("switchDate"){
				$0.title = "Par date"
			}
			<<< DateRow(){
				
				$0.hidden = Condition.function(["switchDate"], { form in
					return !((form.rowBy(tag: "switchDate") as? SwitchRow)?.value ?? false)
				})
				$0.value = Date(timeIntervalSinceReferenceDate: 0)
				$0.tag = "dateEcheance"
			}
			<<< SwitchRow("ajoutAgenda"){
				
				$0.hidden = Condition.function(["switchDate"], { form in
					return !((form.rowBy(tag: "switchDate") as? SwitchRow)?.value ?? false)
				})
				$0.title = "Ajouter à mon agenda"
				$0.tag = "ajoutAgenda"
			}
			<<< SwitchRow("switchKM"){
				$0.title = "Par kilometrage"
			}
			<<< IntRow(){
				$0.hidden = Condition.function(["switchKM"], { form in
					return !((form.rowBy(tag: "switchKM") as? SwitchRow)?.value ?? false)
				})
				$0.title = "Kilométrage"
				$0.value = Int(String(self.car!.kilometrage + self.listeKM.min()!))    // initially selected
				$0.tag = "kilometrageEcheance"
			}
			
			+++ Section("Informations sur le Garage")
			<<< TextRow(){ row in
				row.title = "Nom du garage"
				row.placeholder = "Saisir le nom du garage"
				row.tag = "nomGarage"
				
				}.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			<<< TextRow(){ row in
				row.title = "Adresse"
				row.placeholder = "Saisir l'adresse"
				row.tag = "adresseGarage"
				}.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			<<< ZipCodeRow(){ row in
				row.title = "Code Postal"
				row.placeholder = "Saisir le code postal du garage"
				row.tag = "codePostalGarage"
				}.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			<<< TextRow(){ row in
				row.title = "Ville"
				row.placeholder = "Saisir la ville"
				row.tag = "villeGarage"
				}.cellUpdate { cell, row in
					if !row.isValid {
						cell.textLabel?.textColor = .red
					}
			}
			
			
		

			+++ Section()
			<<< ButtonRow(tag: "Enregistrer").onCellSelection({ (cell, row) in
				row.title = "Enregistrer"
				
				CWProgressHUD.setStyle(.dark)
				CWProgressHUD.show(withMessage: "Enregistrement")
				
				self.entretienItemsList = (self.form.sectionBy(tag: "MVSectionOperations")?.flatMap { (
					$0 as? PushRow<String>)?.value
				})
				/*if let items = self.form.rowBy(tag: "MVSectionOperations") as? MultivaluedSection
				{
					self.entretienItemsList = items.values() as! [String]
					print(items.values())
				}*/
				
				self.oFacture = Facture()
				self.oOperation = operation()
				self.createFactureId()
				
				//Direct access to value
				if let dateFacture = self.form.rowBy(tag: "dateFacture") as? DateRow
				{
					if(dateFacture.value != nil){
						print(dateFacture.value)
						self.oFacture?.dateFacture = dateFacture.value!
					}else{
						self.validationList.append("Date de la Facture")
					}
				}
				if let montantFacture = self.form.rowBy(tag: "montantFacture") as? DecimalRow
				{
					if(montantFacture.value != nil){
						print(montantFacture.value)
						self.oFacture?.prix = Float(montantFacture.value!)
						self.statusValidation = true
					}else{
						self.statusValidation = false
						self.oFacture?.prix = Float(0.00)
						self.validationList.append("Prix")
					}
				}
				if let nomFacture = self.form.rowBy(tag: "nomFacture") as? TextRow
				{
					if(nomFacture.value == nil){
						print(nomFacture.value)
						self.oFacture?.NomFacture = self.nomFacture!
						
					}else if(nomFacture.value == ""){
						print(nomFacture.value)
						self.oFacture?.NomFacture = self.nomFacture!
					}else{
						print(nomFacture.value)
						self.oFacture?.NomFacture = nomFacture.value!
					}
				}
				if let switchDate = self.form.rowBy(tag: "switchDate") as? SwitchRow
				{
					if(switchDate.value == true){
						if let dateEcheance = self.form.rowBy(tag: "dateEcheance") as? DateRow
						{
							if(dateEcheance.value?.description != nil){
								self.prochaineDate = dateEcheance.value
								
								//Add Event to calendar
								if let switchAgenda = self.form.rowBy(tag: "ajoutAgenda") as? SwitchRow{
									if(switchAgenda.value == true){
										self.addEventToCalendar(title: "Entretien du véhicule " + self.car!.pseudo, description: "Penser à la révision du véhicule " + self.car!.pseudo, startDate: self.prochaineDate!, endDate: self.prochaineDate!)
									}
								}
							}
						}
					}
				}
				if let switchStatus = self.form.rowBy(tag: "switchStatus") as? SwitchRow
				{
					if(switchStatus.value == true){
						self.oFacture!.status = true
					}else{
						self.oFacture!.status = false
					}
				}
				if let switchKM = self.form.rowBy(tag: "switchKM") as? SwitchRow
				{
					if(switchKM.value == true){
						if let echeanceKM = self.form.rowBy(tag: "kilometrageEcheance") as? IntRow
						{
							if(echeanceKM.value != nil){
								self.prochainKM = echeanceKM.value
							}
						}
					}
				}
				if let nomGarage = self.form.rowBy(tag: "nomGarage") as? TextRow
				{
					if(nomGarage.value != nil){
						print(nomGarage.value)
						self.oFacture?.nomGarage = nomGarage.value!
						self.statusValidation = true
					}else{
						self.statusValidation = false
						self.validationList.append("Nom du garage")
					}
				}
				if let adresseGarage = self.form.rowBy(tag: "adresseGarage") as? TextRow
				{
					if(adresseGarage.value != nil){
						self.oFacture?.adresseGarage = adresseGarage.value!
						self.statusValidation = true
					}else{
						self.statusValidation = false
						self.validationList.append("Adresse du garage")
					}
				}
				if let codePostalGarage = self.form.rowBy(tag: "codePostalGarage") as? TextRow
				{
					if(codePostalGarage.value != nil){
						self.oFacture?.CPGarage = codePostalGarage.value!
						self.statusValidation = true
					}else{
						self.statusValidation = false
						self.validationList.append("Code postal du garage")
					}
				}
				if let villeGarage = self.form.rowBy(tag: "villeGarage") as? TextRow
				{
					if(villeGarage.value != nil){
						self.oFacture?.villeGarage = villeGarage.value!
						self.statusValidation = true
					}else{
						self.statusValidation = false
						self.validationList.append("Ville du garage")
					}
				}
				if let kilometrage = self.form.rowBy(tag: "kilometrageVehicule") as? IntRow
				{
					if(kilometrage.value != nil){
						self.oFacture?.carKilometrage = kilometrage.value!
						self.statusValidation = true
					}else{
						self.statusValidation = false
						self.validationList.append("kilométrage véhicule")
					}
				}
				self.oFacture?.idFacture = self.idFacture!
				if(self.entretienItemsList != nil){
					
					for operationItem in self.entretienItemsList!
					{
						self.createOperationId()
						self.oOperation = operation()
						
						if let typeIntervention = self.form.rowBy(tag: "typeIntervention") as? TextRow
						{
							print(typeIntervention.value)
							self.oOperation?.type = typeIntervention.value!
						}
						if let dateOperation = self.form.rowBy(tag: "dateFacture") as? DateRow
						{
							print(dateOperation.value)
							self.oOperation?.dateOperation = dateOperation.value!
						}
						if let refFacture = self.form.rowBy(tag: "refFacture") as? TextRow
						{
							if(refFacture.value == ""){
								print(refFacture.value)
								self.oOperation?.refFacture = ""
							}else{
								print(refFacture.value)
								self.oOperation?.refFacture = refFacture.value!
							}
							
						}
						self.oOperation?.NomOperation = operationItem
						self.oOperation?.idFacture = self.idFacture!
						self.oOperation?.idOperation = self.idOperation!
						self.oOperation?.idCar = self.car!.idCar
						
						if(self.prochaineDate != nil){
							self.oOperation?.prochaineEcheanceDate = self.prochaineDate!
						}
						if(self.prochainKM != nil){
							self.oOperation?.prochaineEcheanceKM = self.prochainKM!
						}
						
						if let nomGarage = self.form.rowBy(tag: "nomGarage") as? TextRow
						{
							print(nomGarage.value)
							self.oOperation?.nomGarage = nomGarage.value!
						}
						if let adresseGarage = self.form.rowBy(tag: "adresseGarage") as? TextRow
						{
							print(adresseGarage.value)
							self.oOperation?.adresseGarage = adresseGarage.value!
						}
						if let codePostalGarage = self.form.rowBy(tag: "codePostalGarage") as? TextRow
						{
							print(codePostalGarage.value)
							self.oOperation?.CPGarage = codePostalGarage.value!
						}
						if let villeGarage = self.form.rowBy(tag: "villeGarage") as? TextRow
						{
							print(villeGarage.value)
							self.oOperation?.villeGarage = villeGarage.value!
						}
						if let villeGarage = self.form.rowBy(tag: "villeGarage") as? TextRow
						{
							print(villeGarage.value)
							self.oOperation?.villeGarage = villeGarage.value!
						}
						self.operationsList.append(self.oOperation!)
					}
				}
				
				
				if(self.validationList.count == 0){
					let realm = try! Realm()
					do{
						try! realm.write {
							for operationItem in self.operationsList
							{
								realm.add(operationItem)
							}
							realm.add(self.oFacture!)
						}
					}catch{
						let appearance = SCLAlertView.SCLAppearance(
							showCloseButton: false
						)
						let popup = SCLAlertView(appearance: appearance)
						popup.addButton("OK", backgroundColor: UIColor.gray, textColor: UIColor.white){
						}
						popup.showError("Erreur", subTitle: error as! String)
					}
					CWProgressHUD.dismiss()
					
					if let navController = self.navigationController {
						navController.popViewController(animated: true)
					}
				}else{
					CWProgressHUD.dismiss()
					let validationString = self.validationList.joined(separator: ", ")
					
					let appearance = SCLAlertView.SCLAppearance(
						showCloseButton: false
					)
					let popup = SCLAlertView(appearance: appearance)
					popup.addButton("OK", backgroundColor: UIColor.red, textColor: UIColor.white){
						
					}
					popup.showError("Erreur : Données manquantes", subTitle: "Veuillez remplir les champs suivants svp : " + validationString)
					self.validationList = []
				}
			})
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	func getMaintenanceList() {
		// Determine the file name
		let filename = "MaintenanceList.swift"
		// Read the contents of the specified file
		let contents = try! String(contentsOfFile: filename)
		// Split the file into separate lines
		let lines = contents.split(separator:"\n")
		// Iterate over each line and print the line
		for line in lines {
			print("\(line)")
		}
	}
	
	func onEntretienListSelected(entretienArray: [String]){
		print("Received array = ",entretienArray)
		self.entretienItemsList = entretienArray
		self.tableView.reloadData()
		self.idx = 0
		
	}
	
	func listerTypeOperations(){
		let realm = try! Realm()
		self.listTypeOperations = realm.objects(typeOperation.self).sorted(byKeyPath: "type", ascending: true)
		self.ArraytypeOperations = Array(self.listTypeOperations)
		print("listTypeOperations")
		
		for item in self.listTypeOperations{
			self.listeEntretien.append(item.NomOperation)
			self.listeKM.append(item.intervalleKM)
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
	}
	
	/* Fonction qui crée l'id de la voiture */
	@objc func createFactureId() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.dateFormat = "ddMMYYYYHHmmss"
		self.idFacture = "Facture-" + dateFormatter.string(from: Date())
	}
	
	@objc func createFactureName() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.dateFormat = "dd/MM/YYYY"
		self.nomFacture = "Facture du " + dateFormatter.string(from: Date())
	}
	
	/* Fonction qui crée l'id de l'operation */
	@objc func createOperationId() {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .none
		dateFormatter.dateFormat = "ddMMYYYYHHmmss"
		self.idOperation = "Op-" + dateFormatter.string(from: Date())
	}
	
	func getTimestamp() -> String {
		//timestamp =
		return DateFormatter.localizedString(from: Date(), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
	}
	
	func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
		DispatchQueue.global(qos: .background).async { () -> Void in
			let eventStore = EKEventStore()
			
			eventStore.requestAccess(to: .event, completion: { (granted, error) in
				if (granted) && (error == nil) {
					let event = EKEvent(eventStore: eventStore)
					event.title = title
					event.startDate = startDate
					event.endDate = endDate
					event.notes = description
					event.calendar = eventStore.defaultCalendarForNewEvents
					do {
						try eventStore.save(event, span: .thisEvent)
					} catch let e as NSError {
						completion?(false, e)
						return
					}
					
					let appearance = SCLAlertView.SCLAppearance(
						showCloseButton: false
					)
					let popup = SCLAlertView(appearance: appearance)
					popup.addButton("OK", backgroundColor: UIColor.red, textColor: UIColor.white){
						
					}
					popup.showInfo("Confirmation planification dans l'agenda", subTitle: "Un rappel de l'échéance vient d'être ajouté à votre agenda.")
					
					completion?(true, nil)
					
				} else {
					completion?(false, error as NSError?)
				}
			})
		}
	}
}
