//
//  editTypeOperationItem.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 04/08/2019.
//  Copyright © 2019 Edgarr "

import Foundation
import Eureka
import ImageRow
import RealmSwift
import CWProgressHUD
import SCLAlertView


class editTypeOperationItem: FormViewController {
	
	var type:String?
	var idOperation:String?
	var objOperation:typeOperation?
	var validation:Bool?
	var imageOperation:NSData?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		form
		
		+++ Section()
		<<< TextRow() {
			$0.title = "Type"
			$0.value = self.type // initially selected
			$0.tag = "type"
			$0.disabled = true
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
		}
			
		+++ Section()
		<<< ImageRow("imageTypeOperation") { row in
			row.title = "Image de l'opération"
			row.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
			row.clearAction = .yes(style: UIAlertAction.Style.destructive)
			}.onChange() { row in
				let image = row.value
				var data = NSData()
				self.imageOperation = image!.jpegData(compressionQuality: 0.9) as NSData?
			}
			
		+++ Section()
		<<< TextRow() {
			$0.title = "Opération"
			$0.placeholder = "ex : Vidange huile moteur" // initially selected
			$0.tag = "nomOperation"
			$0.add(rule: RuleRequired())
			$0.validationOptions = .validatesOnChange
		}
		
		<<< IntRow() {
			$0.title = "Périodicité en km"
			$0.placeholder = "ex: 5000" // initially selected
			$0.tag = "PeriodiciteKM"
			$0.validationOptions = .validatesOnChange
		}
		
		<<< IntRow() {
			$0.title = "Périodicité en années"
			$0.placeholder = "ex : 1 an" // initially selected
			$0.tag = "PeriodiciteDuree"
			$0.validationOptions = .validatesOnChange
		}
		
		<<< TextAreaRow() {
			$0.title = "Commentaire"
			$0.placeholder = "Saisir un commentaire" // initially selected
			$0.tag = "Commentaire"
			$0.validationOptions = .validatesOnChange
		}
		
		+++ Section()
		<<< ButtonRow(){
			$0.title = "Enregistrer"
		}.cellSetup() {
			cell, row in
			cell.backgroundColor = UIColor.green
			cell.tintColor = UIColor.white
		}.onCellSelection({
			(cell, row) in
			self.setOperationId()
			self.objOperation = typeOperation()
			self.objOperation?.idTypeOperation = self.idOperation!
			if let type = self.form.rowBy(tag: "type") as? TextRow
			{
				if(type.value != nil){
					self.objOperation?.type = type.value!
				}
			}
			if let nom = self.form.rowBy(tag: "nomOperation") as? TextRow
			{
				if(nom.value != nil){
					self.objOperation?.NomOperation = nom.value!
					self.validation = true
				}else{
					
					let appearance = SCLAlertView.SCLAppearance(
						showCloseButton: false
					)
					let popup = SCLAlertView(appearance: appearance)
					popup.addButton(textStrings.strOK,backgroundColor: UIColor.green, textColor: UIColor.white){}
					popup.showError(textStrings.titleNomOperationNOK, subTitle: textStrings.messageNomOperationNOK)
					self.validation = false
				}
			}
			if let KM = self.form.rowBy(tag: "PeriodiciteKM") as? IntRow
			{
				if(KM.value != nil){
					self.objOperation?.intervalleKM = KM.value!
				}
			}
			if let duree = self.form.rowBy(tag: "PeriodiciteDuree") as? IntRow
			{
				if(duree.value != nil){
					self.objOperation?.intervalleDate = String(duree.value!) + " an"
				}
			}
			if let commentaire = self.form.rowBy(tag: "Commentaire") as? TextAreaRow
			{
				if(commentaire.value != nil){
					self.objOperation?.commentaire = commentaire.value!
				}
			}
			
			if(self.imageOperation != nil){
				self.objOperation?.imageOperation = self.imageOperation
			}else{
				self.objOperation?.imageOperation = UIImage(named: "icon_fuels")!.jpegData(compressionQuality: 0.9) as NSData?
			}
			
			if(self.validation == true){
				let realm = try! Realm()
				try! realm.write {
					realm.add(self.objOperation!)
				}
				self.navigationController?.popViewController(animated: true)
			}
		})
		
		
	}
	
	func setOperationId(){
		let realm = try! Realm()
		let nbOperation = realm.objects(typeOperation.self).count
		self.idOperation = "TypeOp" + String(nbOperation + 1)
	}
}
