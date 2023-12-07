//
//  EntretiensConfiguration.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 02/08/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation
import Eureka
import RealmSwift
import CWProgressHUD


class EntretiensConfiguration: FormViewController {

	var ArraytypeOperations:[typeOperation] = []
	var listTypeOperations:Results<typeOperation>!
	var listTypeOperationsToSave:[typeOperation] = []
	var listTypes:[String] = []
	var periodicite:String = "Kilométrage"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		//listerTypeOperations()
		
		form +++ Section("Type de périodicité")
		
		<<< ActionSheetRow<String>() {
			$0.title = "Périodicité d'entretien"
			$0.selectorTitle = "Choisir la périodicité"
			$0.options = ["Durée","Kilométrage"]
			$0.value = "Par KM"    // initially selected
			$0.tag = "periodicite"
		}.onChange { row in
			self.periodicite = row.value!
			self.clearForm(ofForm: self.form)
			self.buildForm(toForm: self.form)
		}
		
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
	
	func listerTypeOperations(){
		let realm = try! Realm()
		self.listTypeOperations = realm.objects(typeOperation.self).sorted(byKeyPath: "type", ascending: true)
		self.ArraytypeOperations = Array(self.listTypeOperations)
		
		for elt in self.listTypeOperations{
			let type = elt.type
			if !self.listTypes.contains(type){
				self.listTypes.append(type)
			}
		}
		
		print("listTypeOperations")
	}
	
	func listerOperationsByType(typeOp: String){
		
		let realm = try! Realm()
		self.listTypeOperations = realm.objects(typeOperation.self).filter("type = %@",typeOp)
		self.ArraytypeOperations = Array(self.listTypeOperations)
		
		print("listTypeOperations")
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.isNavigationBarHidden = false
		listerTypeOperations()
		tableView.reloadData()
	}
	
	private func buildForm(toForm form: Form){
		listerTypeOperations()
		var indx:Int = 0
		for type in self.listTypes{
			let s = Section(type)
			listerOperationsByType(typeOp: type)
			for typeOperationItem in self.listTypeOperations{
				if(self.periodicite == "Kilométrage"){
					let intRow = IntRow(typeOperationItem.idTypeOperation){
						$0.title = typeOperationItem.NomOperation
						$0.value = typeOperationItem.intervalleKM    // initially selected
						$0.tag = typeOperationItem.idTypeOperation
						$0.add(rule: RuleRequired())
						
						let deleteAction = SwipeAction(style: .destructive, title: "Supprimer") {
							(action, row, completionHandler) in
							print("Supprimer")
							
							let realm = try! Realm()
							try! realm.write {
								realm.delete(typeOperationItem)
							}
							completionHandler?(true)
						}
						
						$0.trailingSwipe.actions = [deleteAction]
						
						
					}
					s.append(intRow)
				}else{
					let dateRow = TextRow(typeOperationItem.idTypeOperation){
						$0.title = typeOperationItem.NomOperation
						$0.value = typeOperationItem.intervalleDate    // initially selected
						$0.tag = typeOperationItem.idTypeOperation
						$0.add(rule: RuleRequired())
						
						let deleteAction = SwipeAction(style: .destructive, title: "Supprimer") {
							(action, row, completionHandler) in
							print("Supprimer")
							
							let realm = try! Realm()
							try! realm.write {
								realm.delete(typeOperationItem)
							}
							completionHandler?(true)
						}
						
						$0.trailingSwipe.actions = [deleteAction]
					}
					s.append(dateRow)
				}
			}
			let saveBtnRow = ButtonRow("addOperation" + String(indx)){
				$0.title = "Ajouter une operation " + type
			}.cellSetup() {cell, row in
				cell.backgroundColor = UIColor.darkGray
				cell.tintColor = UIColor.white
			}.onCellSelection({ (cell, row) in
				let VC = editTypeOperationItem()
				VC.type = type
				self.navigationController?.pushViewController(VC, animated: true)
			})
			s.append(saveBtnRow)
			form.append(s)
			indx += 1
		}
		
		let sct = Section()
		let btnSaveForm = ButtonRow("saveBtn"){
				$0.title = "Enregistrer"
			}.cellSetup() {cell, row in
				cell.backgroundColor = UIColor.red
				cell.tintColor = UIColor.white
			}.onCellSelection({ (cell, row) in
				
				CWProgressHUD.show()
				
				for aRow in 0 ... self.listTypeOperations.count-1 {
					// The trick here is to use the `self.form.sectionBy(tag: "")! <<<` then add your row type.
					// You can add any row types after the <<< just as you normally would in a standard Eureka form.
					// The tag is the important part. This means you can add rows to any section that you have tagged.
					let id = self.listTypeOperations[aRow].idTypeOperation
					
					let typeOperationToSave = typeOperation()
					typeOperationToSave.idTypeOperation = id
					typeOperationToSave.imageOperation = self.listTypeOperations[aRow].imageOperation
					typeOperationToSave.intervalleDate = self.listTypeOperations[aRow].intervalleDate
					typeOperationToSave.intervalleKM = self.listTypeOperations[aRow].intervalleKM
					typeOperationToSave.NomOperation = self.listTypeOperations[aRow].NomOperation
					typeOperationToSave.type = self.listTypeOperations[aRow].type
					
					if let km = self.form.rowBy(tag: id) as? IntRow
					{
						typeOperationToSave.intervalleKM = km.value!
					}
					
					self.listTypeOperationsToSave.append(typeOperationToSave)
				}
				
				let realm = try! Realm()
				try! realm.write {
					for typeOpToSave in self.listTypeOperationsToSave
					{
						realm.add(typeOpToSave, update: .modified)
					}
				}
				CWProgressHUD.dismiss()
				self.navigationController?.popViewController(animated: true)
				
			})
			sct.append(btnSaveForm)
			form.append(sct)
	}

}
