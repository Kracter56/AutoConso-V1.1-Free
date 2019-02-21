//
//  StatsAutoTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 14/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift

class StatsAutoTableViewController: UITableViewController {

    var idCar:String?
    var carItem:[Car] = []
    var consoItem:[Conso] = []
    var realm:Realm?
    var distanceUnit = ""
    var currencyUnit = ""
    var volumeUnit = ""
    
    
    @IBOutlet weak var labelConsoMini: UILabel!
    @IBOutlet weak var labelDateRecordMini: UILabel!
    @IBOutlet weak var labelConsoMaxi: UILabel!
    @IBOutlet weak var labelDateConsoMaxi: UILabel!
    @IBOutlet weak var labelConsoMoyenne: UILabel!
    @IBOutlet weak var labelDistanceTotale: UILabel!
    @IBOutlet weak var labelFraisCarburantTotal: UILabel!
    @IBOutlet weak var labelAutonomieMaximale: UILabel!
    @IBOutlet weak var labelAutonomieMoyenne: UILabel!
    @IBOutlet weak var labelAutonomieMinimale: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("StatsAutoTableViewController:realmInit")
        let realm = try! Realm()
        let userSettings = UserDefaults.standard
        
        var distanceUnit = "km"
        var volumeUnit = "L"
        var currencyUnit = "€"
        
        if(settingsDataAlreadyExist(Key: "devise")){
            currencyUnit = userSettings.object(forKey: "devise") as! String
        }
        if(settingsDataAlreadyExist(Key: "distance")){
            distanceUnit = userSettings.object(forKey: "distance") as! String
        }
        if(settingsDataAlreadyExist(Key: "volume")){
            volumeUnit = userSettings.object(forKey: "volume") as! String
        }
        
        let idCar = self.idCar
        let carItem = realm.objects(Car.self).filter("idCar = %@",idCar).first
        let consoItem = realm.objects(Conso.self).filter("carName = %@",carItem!.pseudo)
        
        if(consoItem.count > 0){
            let consoMoyenne:Float = consoItem.average(ofProperty: "conso")!
            
            let consoMini:Float = consoItem.min(ofProperty: "conso")!
            let consoMaxi:Float = consoItem.max(ofProperty: "conso")!
            
            let lastkm:Int = consoItem.max(ofProperty: "carKilometrage")!
            let fraisCarburant:Double = consoItem.sum(ofProperty: "prix")
            
            let autonomieMin:Float = consoItem.min(ofProperty: "carKmParcourus")!
            let autonomieMoy:Float = consoItem.average(ofProperty: "carKmParcourus")!
            let autonomieMax:Float = consoItem.max(ofProperty: "carKmParcourus")!
            
            let roundConsoMoyenne = (consoMoyenne * 1000).rounded() / 1000
            let roundFraisCarburant = (fraisCarburant * 1000).rounded() / 1000
            let roundConsoMini = (consoMini * 1000).rounded() / 1000
            let roundConsoMaxi = (consoMaxi * 1000).rounded() / 1000
            
            self.labelConsoMoyenne?.text = roundConsoMoyenne.description + " " + volumeUnit + "/100 " + distanceUnit
            self.labelConsoMini?.text = roundConsoMini.description + " " + volumeUnit + "/100 " + distanceUnit
            self.labelConsoMaxi?.text = roundConsoMaxi.description + " " + volumeUnit + "/100 " + distanceUnit
            
            self.labelAutonomieMaximale?.text = autonomieMax.description + " " + currencyUnit
            self.labelAutonomieMoyenne?.text = autonomieMoy.description + " " + distanceUnit
            self.labelAutonomieMinimale?.text = autonomieMin.description + " " + distanceUnit
            
            self.labelDistanceTotale?.text = lastkm.description + " " + distanceUnit
            self.labelFraisCarburantTotal?.text = roundFraisCarburant.description + " " + currencyUnit
            
            self.labelConsoMini?.text = roundConsoMini.description + " " + volumeUnit + "/100 " + distanceUnit
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func settingsDataAlreadyExist(Key: String) -> Bool {
        return UserDefaults.standard.object(forKey: Key) != nil
    }
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }*/

    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
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
