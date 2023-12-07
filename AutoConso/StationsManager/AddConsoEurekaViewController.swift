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

class AddStationEurekaViewController: FormViewController {
	
	var realm:Realm?
	var listOfCars:[Car] = []
	
	let listOfStationServices:[String] = ["AGIP", "ANTAR", "AUCHAN", "AVIA", "BP", "CARREFOUR", "DYNEFF", "E.LECLERC", "ELF", "ESSO EXPRESS", "ESSO", "EXXON", "FINA", "IRVING", "SHELL", "TOTAL ACCESS", "TOTAL", "U"]
	let listOfTypesCarburants:[String] = ["ESSENCE PLUS (Haut de gamme)", "SUPER", "SANS PLOMB 98", "SANS PLOMB 95", "SANS PLOMB 95 E10", "DIESEL PLUS (Haut de gamme)", "GAZOLE", "ETHANOL", "FlexFuel", "GPL"]
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
		
		form
		+++ Section(StationSectionTitle)
			<<< PushRow<String>() {
				$0.title = "Marque de la station"
				$0.selectorTitle = "Sélectionner une station"
				$0.options = self.listOfStationServices
				$0.value = "TOTAL"    // initially selected
			}
			
		+++ Section(StationAddressTitle)
			<<< TextRow() { // 3
				$0.title = "Adresse" //4
				$0.placeholder = "Saisir l'adresse"
				$0.onChange { [unowned self] row in //6
					//self.viewModel.title = row.value
					}
			}
			<<< ZipCodeRow() { // 3
				$0.title = "Code Postal" //4
				$0.placeholder = "Saisir le code postal"
				$0.onChange { [unowned self] row in //6
					//self.viewModel.title = row.value
				}
			}
			<<< TextRow() { // 3
				$0.title = "Ville" //4
				$0.placeholder = "Saisir la ville"
				$0.onChange { [unowned self] row in //6
					//self.viewModel.title = row.value
				}
			}
			
		+++ Section(StationCarburantTypesTitle)
			<<< MultipleSelectorRow<String>() {
				$0.title = "Carburants"
				$0.selectorTitle = "Sélectionner les carburants disponibles"
				$0.options = self.listOfTypesCarburants
				//$0.value = "GAZOLE"    // initially selected
			}
			
		+++ Section(ServicesListTitle)
			<<< MultipleSelectorRow<String>() {
				$0.title = "Services"
				$0.selectorTitle = "Sélectionner les services de la station"
				$0.options = self.listOfServices
		}
	}
	
	func getCarsList(){
		let realm = try! Realm()
		self.listOfCars = Array(realm.objects(Car.self))
	}
}
extension AddConsoEurekaViewController{

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
