//
//  operationsTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 25/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift
import EventKit
import CWProgressHUD

class operationsTableViewController: UITableViewController {

	var idFacture:String?
	var operationsList:Results<operation>!
	var operations:[operation] = []
	var Mode:String?
	var idCar:String?
	var car:Car?
	
	func listOperationsByFactureId(){
		let realm = try! Realm()
		self.operationsList = realm.objects(operation.self).filter("idFacture = %@",self.idFacture!)
		self.operations = Array((self.operationsList)!)
		print("listOperations")
	}
	
	func listOperations(){
		let realm = try! Realm()
		self.operationsList = realm.objects(operation.self).filter("idCar = %@",self.idCar!)
		self.operations = Array((self.operationsList)!)
		print("listOperations")
	}
	
	func listFutursOperations(){
		
		CWProgressHUD.show(withMessage: "Recherche")
		
		let eventStore = EKEventStore()
		let calendars = eventStore.calendars(for: .event)
		
		for calendar in calendars {
			//if calendar.title == "Work" {
				
				let oneMonthAgo = NSDate(timeIntervalSinceNow: 0)
				let TwoYearsAfter = NSDate(timeIntervalSinceNow: 2*365*24*3600)
				
			let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo as Date, end: TwoYearsAfter as Date, calendars: [calendar])
				
			var events = eventStore.events(matching: predicate)
				for event in events {
					var titre:String?
						titre = event.title
					if((titre as! NSString).contains(self.car!.pseudo)){
						let op = operation()
						//titles.append(event.title)
						op.NomOperation = event.title
						op.dateOperation = event.startDate
						self.operations.append(op)
					}
				}
		}
		CWProgressHUD.dismiss()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

		if(self.Mode == "listOperations"){
			listOperations()
		}
		if(self.Mode == "listOperationsByFactureId"){
			listOperationsByFactureId()
			print("idFacture = " + self.idFacture!)
			print("nb operation = " + self.operationsList.count.description)
		}
		if(self.Mode == "listFutursOperations"){
			listFutursOperations()
		}
		
		if self.operations.count == 0 {
			if(self.Mode == "listFutursOperations"){
				self.tableView.setEmptyMessage(textStrings.emptyOperationMessage)
			}
			if(self.Mode == "listOperationsByFactureId"){
				self.tableView.setEmptyMessage(textStrings.emptyFactureMessage)
			}
		} else {
			self.tableView.restore()
		}
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.operations.count
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "operationCell", for: indexPath) as! operationsTableViewCell

        // Configure the cell...
		cell.labelOperation.text = self.operations[indexPath.row].NomOperation
		cell.labelCarKm.text = self.operations[indexPath.row].carKilometrage.description + " km"
		cell.labelNomGarage.text = self.operations[indexPath.row].nomGarage
		
		/*let imageOperation = UIImage(data: self.operations[indexPath.row].imageOperation! as Data)
		cell.imageTypeOperation.image = imageOperation*/

        return cell
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
