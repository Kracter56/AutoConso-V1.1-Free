//
//  EntretienTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 12/07/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import UIKit

class EntretienTableViewController: UITableViewController {

	@IBOutlet var tableViewEntretien: UITableView!
	var addEntretienVC: AddEntretienViewController?
	var entretienArray = [String]()
	
	let section = ["Huiles et liquides", "Filtres", "Batterie", "Système de Freinage", "Pneus"]
	
	let items = [["Vidange huile moteur", "Vidange boite de vitesse manuelle", "Vidange boite de vitesse automatique", "Mise à niveau liquide lave glace", "Mise à niveau liquide de refroidissement", "Vidange liquide de frein"], ["Remplacement filtre à huile", "Remplacement filtre à air", "Remplacement filtre à carburant", "Remplacement filtre habitacle"], ["Diagnostic Batterie", "Remplacement de batterie"], ["Remplacement plaquettes de frein AV", "Remplacement plaquettes de frein AR", "Remplacement disques de frein AV", "Remplacement disques de frein AR"],["Remplacement pneus AV", "Remplacement pneus AR", "Parallélisme AV", "Parallélisme AR", "Contrôle de géométrie"]]
	
	let pictos = [["icon_vidange_moteur", "icon_vidange_bvm", "icon_vidange_bva", "icon_entretien", "icon_entretien", "icon_entretien"], ["icon_entretien", "icon_entretien", "icon_entretien", "icon_entretien"], ["icon_entretien", "icon_entretien"], ["icon_entretien", "icon_entretien", "icon_entretien", "icon_entretien"],["icon_entretien", "icon_entretien", "icon_entretien", "icon_entretien", "icon_entretien"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableViewEntretien.delegate = self
        self.tableViewEntretien.dataSource = self
		
		/* Enable multiple selections */
		self.tableViewEntretien.allowsMultipleSelection = true
		self.tableViewEntretien.allowsMultipleSelectionDuringEditing = true
		
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.section.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.items[section].count
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "EntretienItemCell", for: indexPath) as! EntretienTableViewCell
		// Configure the cell...
		cell.imageEntretienItem.image = UIImage(named: self.pictos[indexPath.section][indexPath.row])
		cell.labelEntretien?.text = self.items[indexPath.section][indexPath.row]
		cell.labelKM.text = "300000 km"
		cell.labelNomGarage.text = "JetPneu Eurotyre"

		/* Toggle Check / Uncheck */
		if cell.isSelected
		{
			cell.isSelected = false
			if cell.accessoryType == UITableViewCell.AccessoryType.none
			{
				cell.accessoryType = UITableViewCell.AccessoryType.checkmark
			}
			else
			{
				cell.accessoryType = UITableViewCell.AccessoryType.none
			}
		}
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		return self.section[section]
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		//let cell = tableView.dequeueReusableCell(withIdentifier: "EntretienItemCell", for: indexPath)
		let cell = tableView.cellForRow(at: indexPath as IndexPath) as! EntretienTableViewCell
		let entretienItem = cell.labelEntretien.text as! String
		if cell.isSelected
		{
			if cell.accessoryType == UITableViewCell.AccessoryType.none
			{
				self.entretienArray.filter { $0 != entretienItem }
			}
			else
			{
				self.entretienArray.append(entretienItem)
			}
			print(self.entretienArray)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		if self.isMovingFromParent {
			// Your code...
			self.addEntretienVC?.onEntretienListSelected(entretienArray: self.entretienArray)
			//self.navigationController?.popViewController(animated: true)
		}
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
