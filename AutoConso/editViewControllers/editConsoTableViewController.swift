//
//  editConsoTableViewController.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 01/11/2018.
//  Copyright © 2018 Edgar PETRUS. All rights reserved.
//

import UIKit
import RealmSwift

class editConsoTableViewController: UITableViewController {

    var consoItem: Conso!
    var carItem: Car!
    var realm:Realm?
    var station:Station?
    var source:String?
    

    @IBOutlet weak var labelMarqueModele: UILabel!
    @IBOutlet weak var labelPseudo: UILabel!
    @IBOutlet weak var imageVehicle: UIImageView!
    
    @IBOutlet weak var editFieldNomStation: UITextField!
    @IBOutlet weak var editFieldStationAdresse: UITextField!
    @IBOutlet weak var editFieldCP: UITextField!
    @IBOutlet weak var editFieldStationVille: UITextField!
    @IBOutlet weak var imageStation: UIImageView!
    
    @IBOutlet weak var editFieldDateConso: UITextField!
    @IBOutlet weak var editFieldCarburant: UITextField!
    @IBOutlet weak var editFieldVolumeCarburant: UITextField!
    
    @IBOutlet weak var editFieldKilometrage: UITextField!
    @IBOutlet weak var editFieldKmParcourus: UITextField!
    
    @IBOutlet weak var editFieldNotes: UITextField!
    @IBAction func btnFermer(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("editConsoTableViewController:realmInit")
        
        if(self.source == "StationsVC"){
            /* Si la source de ce ViewController est StationsVC, supprimer ce VC de la mémoire */
            let VCCount = self.navigationController!.viewControllers.count
            self.navigationController?.viewControllers.remove(at: self.navigationController!.viewControllers.count - 2)
        }
        
        let realm = try! Realm()
        let carItem = realm.objects(Car.self).filter("pseudo LIKE %@",consoItem.carName).first
        
        print("Reception de " + consoItem.idConso)
        let vehicle = carItem?.type
        
        if(vehicle == "SCOOTER"){
            imageVehicle?.image = UIImage(named: "icon_scooter")
        }
        if(vehicle == "MOTO"){
            imageVehicle?.image = UIImage(named: "icon_moto")
        }
        if(vehicle == "VOITURE"){
            imageVehicle?.image = UIImage(named: "3Dcar")
        }
        
        labelPseudo?.text = consoItem.carName
        labelMarqueModele?.text = (carItem?.marque)! + " " + (carItem?.modele)!
        
        if(station == nil){
            editFieldNomStation?.text = consoItem.nomStation
            editFieldStationAdresse?.text = consoItem.adresseStation
            editFieldCP?.text = consoItem.CPStation.description
            editFieldStationVille?.text = consoItem.villeStation
        }else{
            editFieldNomStation?.text = station?.nomStation
            editFieldStationAdresse?.text = station?.adresse
            editFieldCP?.text = station?.codePostal
            editFieldStationVille?.text = station?.ville
        }
        
        let stationImage = UIImage(data: consoItem.data! as Data)
        imageStation.image = stationImage
        editFieldCarburant?.text = consoItem.typeCarburant
        editFieldVolumeCarburant?.text = consoItem.volConso.description
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        editFieldDateConso?.text = formatter.string(from: consoItem.dateConso)
        
        editFieldKilometrage?.text = consoItem.carKilometrage.description
        editFieldKmParcourus?.text = consoItem.carKmParcourus.description
        editFieldNotes?.text = consoItem.commentaire
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    @IBAction func btnEnregistrer(_ sender: UIBarButtonItem) {
        let realm = try! Realm()
        let dateFormatter = DateFormatter()
        let dateFormat = "dd/MM/yyyy"
        dateFormatter.dateFormat = dateFormat
        let dateConso = dateFormatter.date(from: (editFieldDateConso?.text)!)
        
        let idConso = consoItem.idConso
        
        let conso = realm.objects(Conso.self).filter("idConso LIKE %@",idConso).first
            
        try! realm.write {
            conso?.nomStation = (editFieldNomStation?.text)!
            conso?.adresseStation = (editFieldStationAdresse?.text)!
            conso?.CPStation = (editFieldCP?.text)!
            conso?.villeStation = ((editFieldStationVille?.text)!)
            
            conso?.typeCarburant = (editFieldCarburant?.text)!
            //conso?.volConso = Float(editFieldVolumeCarburant?.text)!
            
            conso!.dateConso = dateConso!
            conso?.carKilometrage = Int((editFieldKilometrage?.text)!)!
            //conso?.carKmParcourus = Float(editFieldKmParcourus?.text)!
            
            conso?.commentaire = (editFieldNotes?.text)!
            
            /* Ajouter la voiture dans la base de données */
            realm.add(conso!)
        }
        
        //self.toastMessage("La voiture "+(carItem.modele)+" a bien été modifiée")
        /* Si la source de ce ViewController est StationsVC, supprimer ce VC de la mémoire */
        let VCCount = self.navigationController!.viewControllers.count
        print("VCCount",VCCount)
        self.navigationController?.viewControllers.remove(at: VCCount - 1)
        
        /* Rafraichir la liste des voitures avant affichage */
        self.navigationController?.popViewController(animated: true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.destination is StationsSearchTableViewController
        {
            /* On créer l'id de la station à sélectionner */
            //createStationId()
            let station = Station.self
            
            var searchString = self.editFieldNomStation.text!
            
            if(self.editFieldCP.text != nil){
                searchString = searchString + ", " + self.editFieldCP.text!
            }else{
                if(self.editFieldStationVille.text != nil){
                    searchString = searchString + ", " + self.editFieldStationVille.text!
                }
            }
            
            let vc = segue.destination as? StationsSearchTableViewController
            print("searchString",searchString)
            /* Envoi de la recherche */
            vc!.stationName = self.editFieldNomStation.text!
            vc!.stationVille = self.editFieldStationVille.text!
            vc!.searchString = searchString
            vc!.car = self.carItem
            vc!.oConso = self.consoItem
            //vc?.addConsoVC = self // Je lie les 2 viewControllers pour que quand je sélectionne une donnée de vc, je puisse appeler une fonction de addConso
        }
    }
    // MARK: - Table view data source

    /*override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }*/

    /*override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
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
