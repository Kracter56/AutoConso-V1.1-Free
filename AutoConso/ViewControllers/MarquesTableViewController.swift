//
//  MarquesTableViewController.swift
//  AutoConso-v0
//
//  Created by Edgar PETRUS on 15/10/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit

class MarquesTableViewController: UITableViewController {

    var carsDictionary = [String: [String]]()
    var carSectionTitles = [String]()
    var carBrands = [String]()
    var stringPassed = ""
    var delegate = AddCarViewController()
    
    struct Objects {
        var sectionLettre : String!
        var sectionMarques : [String]!
    }
    
    var objectArray = [Objects]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        carBrands = ["ALFA ROMEO", "AUDI", "BMW", "CADILLAC", "CHEVROLET", "CHRYSLER", "CITROEN", "DACIA", "DAEWOO", "DAIHATSU", "DODGE", "DS", "FIAT", "FORD", "HONDA", "HUMMER", "HYUNDAI", "INFINITI", "ISUZU", "IVECO", "JAGUAR", "KIA", "LADA", "LANCIA", "LAND ROVER", "LEXUS", "MAZDA", "MERCEDES-BENZ", "MG", "MINI", "MITSUBISHI", "NISSAN", "OPEL", "PEUGEOT", "PORSCHE", "RENAULT", "ROVER", "SAAB", "SEAT", "SIMCA", "SKODA", "SMART", "SUZUKI", "SSANGYONG", "SUBARU", "TALBOT", "TESLA", "TOYOTA", "VOLKSWAGEN", "VOLVO"]
        
        // 1
        for carBrand in carBrands {
            let carKey = String(carBrand.prefix(1))
            if var carValues = carsDictionary[carKey] {
                carValues.append(carBrand)
                carsDictionary[carKey] = carValues
            } else {
                carsDictionary[carKey] = [carBrand]
            }
        }
        
        // 2
        carSectionTitles = [String](carsDictionary.keys)
        carSectionTitles = carSectionTitles.sorted(by: { $0 < $1 })
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print(stringPassed)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return carSectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let carKey = carSectionTitles[section]
        if let carValues = carsDictionary[carKey] {
            return carValues.count
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 3
        let cell = tableView.dequeueReusableCell(withIdentifier: "carMarqueCell", for: indexPath) as! MarquesTableViewCell
        
        // Configure the cell...
        let carKey = carSectionTitles[indexPath.section]
        if let carValues = carsDictionary[carKey] {
            //cell.textLabel?.text = carValues[indexPath.row]
            cell.carMarque?.text = carValues[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return carSectionTitles[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return carSectionTitles
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let mainViewController = AddCarViewController()
        /* S'execute à la sélection de la cellule */
        
        let selectedBrand = carBrands[indexPath.row]
        delegate.selectedMarque = selectedBrand
        /* Appel de la fonction onUserBrandSelected dans la classe appelante */
        //delegate.onUserBrandSelected(data: selectedBrand)
        
        //self.tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
