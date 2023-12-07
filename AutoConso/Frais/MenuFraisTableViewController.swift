//
//  MenuFraisTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 28/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift

class MenuFraisTableViewController: UITableViewController {

	var realm:Realm?
	var car:Car?
	var idCar:String?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
		
		//setTitle(title: "Frais du véhicule" + self.car!.pseudo, subtitle: self.idCar!)
		self.navigationItem.title = "Frais du véhicule " + self.car!.pseudo
		self.navigationItem.prompt = "Menu Frais"

    }

    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }*/
	
	/*override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let vw = UIView()
		vw.tintColor = UIColor.red
		vw.
		return vw
	}*/
	
	/*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if(indexPath.row == 1){
			let FactureVC = storyboard?.instantiateViewController(withIdentifier: "menuFraisCell") as! MenuFraisTableViewController
			menuFraisVC.car = car
			menuFraisVC.idCar = car.idCar
			navigationController?.pushViewController(menuFraisVC, animated: true)
		}
	}*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
			
		if(segue.identifier == "maintenanceVCSegue"){
			print("segue.destination = vehLocationScreen")
				
			let indexPath = self.tableView.indexPathForSelectedRow
				
			// titleString is set to the title at the row in the objects array.
			let vc = segue.destination as! MaintenanceTableViewController
			vc.car = car
			vc.idCar = car?.idCar
		}
		
		if(segue.identifier == "operationsVCSegue"){
			print("segue.destination = operationsList")
			
			let indexPath = self.tableView.indexPathForSelectedRow
			
			// titleString is set to the title at the row in the objects array.
			let vc = segue.destination as! operationsTableViewController
			//vc.car = car
			vc.idCar = car?.idCar
			vc.Mode = "listOperations"
		}
		
		if(segue.identifier == "opFutursVCSegue"){
			print("segue.destination = operationsList")
			
			let indexPath = self.tableView.indexPathForSelectedRow
			
			// titleString is set to the title at the row in the objects array.
			let vc = segue.destination as! operationsTableViewController
			//vc.car = car
			vc.idCar = car?.idCar
			vc.car = car
			vc.Mode = "listFutursOperations"
		}
    }
	
	func setTitle(title:String, subtitle:String) -> UIView {
		
		let titleLabel = UILabel(frame: CGRectMake(0, -2, 0, 0))
		
		titleLabel.backgroundColor = UIColor.clear
		titleLabel.textColor = UIColor.gray
		titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
		titleLabel.text = title
		titleLabel.sizeToFit()
		
		let subtitleLabel = UILabel(frame: CGRectMake(0, 18, 0, 0))
		subtitleLabel.backgroundColor = UIColor.clear
		subtitleLabel.textColor = UIColor.black
		subtitleLabel.font = UIFont.systemFont(ofSize: 12)
		subtitleLabel.text = subtitle
		subtitleLabel.sizeToFit()
		
		let titleView = UIView(frame: CGRectMake(0, 0, max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), 30))
		titleView.addSubview(titleLabel)
		titleView.addSubview(subtitleLabel)
		
		let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
		
		if widthDiff < 0 {
			let newX = widthDiff / 2
			subtitleLabel.frame.origin.x = abs(newX)
		} else {
			let newX = widthDiff / 2
			titleLabel.frame.origin.x = newX
		}
		
		return titleView
	}

	func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
		return CGRect(x: x, y: y, width: width, height: height)
	}
	
}
