//
//  MaintenanceTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 10/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import SCLAlertView

class MaintenanceTableViewController: UITableViewController {
	
	var realm:Realm?
	var car:Car?
	var idCar:String?
	var fraisData:Results<Facture>!
	var factures:[Facture] = []
	@IBOutlet var TableViewFrais: UITableView!
	
	@IBAction func btnAddMaintenance(_ sender: UIBarButtonItem) {
		let AddMaintenanceController = AddEntretienViewController()
		AddMaintenanceController.car = self.car
		self.navigationController?.pushViewController(AddMaintenanceController, animated: true)
	}
	
	func listFrais(){
		let realm = try! Realm()
		//self.car = realm.objects(Car.self).filter("idCar = %@",self.idCar).first
		self.fraisData = realm.objects(Facture.self).sorted(byKeyPath: "dateFacture", ascending: false)//.filter("idCar = %@",self.idCar).sorted(byKeyPath: "dateFacture", ascending: false)
		self.factures = Array((self.fraisData)!)
		print("listFrais")
	}
	
	override func viewDidLoad() {
        super.viewDidLoad()

		listFrais()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		if self.factures.count == 0 {
			self.TableViewFrais.setEmptyMessage(textStrings.emptyFactureMessage)
		} else {
			self.TableViewFrais.restore()
		}
		
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
		return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.fraisData.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fraisCell", for: indexPath) as! FraisTableViewCell

        // Configure the cell...
        cell.labelNomFacture?.text = self.fraisData[indexPath.row].NomFacture
        cell.labelDateFacture?.text = self.fraisData[indexPath.row].dateFacture.description
        cell.labelKMVehicule?.text = self.fraisData[indexPath.row].carKilometrage.description
        cell.labelPrixFacture?.text = self.fraisData[indexPath.row].prix.description + "€"
		cell.labelNomGarage.text = self.fraisData[indexPath.row].nomGarage
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let idFacture = self.fraisData[indexPath.row].idFacture

		let VC = storyboard?.instantiateViewController(withIdentifier: "operationsList") as! operationsTableViewController
		VC.idFacture = idFacture
		VC.Mode = "listOperationsByFactureId"
		navigationController?.pushViewController(VC, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		
		let deleteAction = UITableViewRowAction(style: .destructive, title: textStrings.deleteBtn) { (deleteAction, indexPath) -> Void in
			
			//Deletion will go here
			
			let listToBeDeleted = self.fraisData[indexPath.row]
			let appearance = SCLAlertView.SCLAppearance(
				showCloseButton: false
			)
			let deletePopup = SCLAlertView(appearance: appearance)
			
			deletePopup.addButton(textStrings.deleteConsoAlertYes, backgroundColor: UIColor.green, textColor: UIColor.white){
				
				self.realm = try! Realm()
				try! self.realm!.write{
					self.realm!.delete(listToBeDeleted)
					self.toastMessage(textStrings.confirmConsoDelete)
					self.listFrais()
					
					self.TableViewFrais.reloadData()
				}
				
			}
			deletePopup.addButton(textStrings.deleteConsoAlertNo, backgroundColor: UIColor.red, textColor: UIColor.white){
			}
			deletePopup.showWarning(textStrings.deleteFraisAlertMessage, subTitle: textStrings.deleteFraisAlertMessage)
		}
		/*let shareAction = UITableViewRowAction(style: .normal, title: shareBtn) { (shareAction, indexPath) -> Void in
			let listToBeShared = self.consos[indexPath.row]
			
			let date = listToBeShared.dateConso
			/* Conversion de date */
			let formatter = DateFormatter()
			formatter.dateFormat = "dd/MM/yyyy"
			formatter.dateStyle = .short
			formatter.timeStyle = .none
			
			let dateConso = "Date: " + formatter.string(from: date)
			let carKm = "\nKm véhicule: " + listToBeShared.carKilometrage.description + " km"
			let km = "\nKm parcourus: " + listToBeShared.carKmParcourus.description + " km"
			let litres = "\nVol. Carburant: " + listToBeShared.volConso.description + " L"
			let conso = "\nConsommation: " + listToBeShared.conso.description + " L/100km"
			let prix = "\nPrix: " + listToBeShared.prix.description + " €"
			
			let vc = UIActivityViewController(activityItems: [dateConso, carKm, km, litres, conso, prix], applicationActivities: [])
			self.present(vc, animated: true, completion: nil)
		}*/
		
		
		return [deleteAction]
	}

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
